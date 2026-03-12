import CoreML
import Foundation

public enum SileroVADModelError: Error, LocalizedError {
	case modelNotFound
	case invalidFrameSize(expected: Int, actual: Int)
	case predictionFailed
	case missingOutputFeature(String)

	public var errorDescription: String? {
		switch self {
		case .modelNotFound:
			return "Could not locate the bundled Silero VAD CoreML model."
		case .invalidFrameSize(let expected, let actual):
			return "Invalid VAD frame size. Expected \(expected), got \(actual)."
		case .predictionFailed:
			return "Silero VAD model prediction failed."
		case .missingOutputFeature(let name):
			return "Missing required output feature: \(name)"
		}
	}
}

public final class SileroVADModel: @unchecked Sendable {
	private let configuration: VADConfiguration
	private let model: MLModel

	private var hiddenState: MLMultiArray
	private var cellState: MLMultiArray

	public init(configuration: VADConfiguration = .init()) throws {
		self.configuration = configuration

		let rawModelURL = try Self.locateRawModelURL()
		let loadableURL = try Self.makeLoadableModelURL(from: rawModelURL)

		let modelConfig = MLModelConfiguration()
		modelConfig.computeUnits = .all

		self.model = try MLModel(contentsOf: loadableURL, configuration: modelConfig)
		self.hiddenState = try Self.makeZeroArray(shape: [1, 128])
		self.cellState = try Self.makeZeroArray(shape: [1, 128])
	}

	public func predictProbability(frame: [Float]) throws -> Float {
		guard frame.count == configuration.frameSize else {
			throw SileroVADModelError.invalidFrameSize(
				expected: configuration.frameSize,
				actual: frame.count
			)
		}

		let audioInput = try Self.makeArray(from: frame, shape: [1, configuration.frameSize])

		let provider = try MLDictionaryFeatureProvider(dictionary: [
			"audio_input": MLFeatureValue(multiArray: audioInput),
			"hidden_state": MLFeatureValue(multiArray: hiddenState),
			"cell_state": MLFeatureValue(multiArray: cellState)
		])

		let result = try model.prediction(from: provider)

		guard let vadOutput = result.featureValue(for: "vad_output")?.multiArrayValue else {
			throw SileroVADModelError.missingOutputFeature("vad_output")
		}

		guard let newHidden = result.featureValue(for: "new_hidden_state")?.multiArrayValue else {
			throw SileroVADModelError.missingOutputFeature("new_hidden_state")
		}

		guard let newCell = result.featureValue(for: "new_cell_state")?.multiArrayValue else {
			throw SileroVADModelError.missingOutputFeature("new_cell_state")
		}

		self.hiddenState = newHidden
		self.cellState = newCell

		guard vadOutput.count > 0 else {
			throw SileroVADModelError.predictionFailed
		}

		return vadOutput[0].floatValue
	}

	public func resetState() throws {
		self.hiddenState = try Self.makeZeroArray(shape: [1, 128])
		self.cellState = try Self.makeZeroArray(shape: [1, 128])
	}

	public var debugInputFeatureNames: [String] {
		Array(model.modelDescription.inputDescriptionsByName.keys)
	}

	public var debugOutputFeatureNames: [String] {
		Array(model.modelDescription.outputDescriptionsByName.keys)
	}

	public var debugInputDescriptions: [String: MLFeatureDescription] {
		model.modelDescription.inputDescriptionsByName
	}

	public var debugOutputDescriptions: [String: MLFeatureDescription] {
		model.modelDescription.outputDescriptionsByName
	}

	private static func locateRawModelURL() throws -> URL {
		let bundle = Bundle.module
		guard let resourceURL = bundle.resourceURL else {
			throw SileroVADModelError.modelNotFound
		}

		let candidateNames = [
			"silero-vad-unified-v6.0.0.mlpackage",
			"silero-vad-unified-v6.0.0.mlmodelc",
			"silero-vad-unified-v6.0.0.mlmodel"
		]

		let fileManager = FileManager.default

		if let enumerator = fileManager.enumerator(at: resourceURL, includingPropertiesForKeys: nil) {
			for case let url as URL in enumerator {
				if candidateNames.contains(url.lastPathComponent) {
					return url
				}
			}
		}

		throw SileroVADModelError.modelNotFound
	}

	private static func makeLoadableModelURL(from rawURL: URL) throws -> URL {
		if rawURL.pathExtension == "mlmodelc" {
			return rawURL
		}
		return try MLModel.compileModel(at: rawURL)
	}

	private static func makeZeroArray(shape: [Int]) throws -> MLMultiArray {
		let nsShape = shape.map { NSNumber(value: $0) }
		let array = try MLMultiArray(shape: nsShape, dataType: .float32)

		for index in 0..<array.count {
			array[index] = 0
		}

		return array
	}

	private static func makeArray(from values: [Float], shape: [Int]) throws -> MLMultiArray {
		let nsShape = shape.map { NSNumber(value: $0) }
		let array = try MLMultiArray(shape: nsShape, dataType: .float32)

		for (index, value) in values.enumerated() {
			array[index] = NSNumber(value: value)
		}

		return array
	}
}
