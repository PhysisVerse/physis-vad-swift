import Testing
@testable import PhysisVAD

struct SileroVADModelTests {
	@Test
	func modelLoads() throws {
		let model = try SileroVADModel()

		#expect(!model.debugInputFeatureNames.isEmpty)
		#expect(!model.debugOutputFeatureNames.isEmpty)
	}

	@Test
	func modelRunsPredictionOnSilentFrame() throws {
		let model = try SileroVADModel()
		let silentFrame = Array(repeating: Float(0), count: 576)

		let probability = try model.predictProbability(frame: silentFrame)

		#expect(probability >= 0)
		#expect(probability <= 1)
	}
}
