import Foundation

public actor VADProcessor {
	private let configuration: VADConfiguration
	private let model: SileroVADModel

	private var frameBuffer = AudioFrameBuffer()
	private var stateMachine: VoiceActivityStateMachine

	public init(configuration: VADConfiguration = .init()) throws {
		self.configuration = configuration
		self.model = try SileroVADModel(configuration: configuration)
		self.stateMachine = VoiceActivityStateMachine(configuration: configuration)
	}

	public func process(samples: [Float]) throws -> [VoiceActivityEvent] {
		frameBuffer.append(samples)

		var events: [VoiceActivityEvent] = []

		while let frame = frameBuffer.popFrame(frameSize: configuration.frameSize) {
			let probability = try model.predictProbability(frame: frame)
			events.append(contentsOf: stateMachine.process(probability: probability))
		}

		return events
	}

	public func reset() throws {
		frameBuffer.reset()
		stateMachine.reset()
		try model.resetState()
	}

	public var currentState: VoiceActivityState {
		stateMachine.currentState
	}
}
