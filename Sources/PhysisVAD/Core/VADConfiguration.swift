import Foundation

public struct VADConfiguration: Sendable, Equatable {
	public var sampleRate: Double
	public var frameSize: Int

	public var speechStartThreshold: Float
	public var speechEndThreshold: Float

	public var startTriggerFrames: Int
	public var endTriggerFrames: Int

	public var emitSpeechProbability: Bool

	public init(
		sampleRate: Double = 16_000,
		frameSize: Int = 576,
		speechStartThreshold: Float = 0.60,
		speechEndThreshold: Float = 0.35,
		startTriggerFrames: Int = 3,
		endTriggerFrames: Int = 8,
		emitSpeechProbability: Bool = true
	) {
		self.sampleRate = sampleRate
		self.frameSize = frameSize
		self.speechStartThreshold = speechStartThreshold
		self.speechEndThreshold = speechEndThreshold
		self.startTriggerFrames = startTriggerFrames
		self.endTriggerFrames = endTriggerFrames
		self.emitSpeechProbability = emitSpeechProbability
	}
}
