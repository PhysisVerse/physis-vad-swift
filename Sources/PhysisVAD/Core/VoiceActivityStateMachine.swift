import Foundation

public struct VoiceActivityStateMachine: Sendable {
	private let configuration: VADConfiguration

	private var state: VoiceActivityState = .inactive
	private var activeFrameCount: Int = 0
	private var inactiveFrameCount: Int = 0

	public init(configuration: VADConfiguration = .init()) {
		self.configuration = configuration
	}

	public mutating func process(probability: Float) -> [VoiceActivityEvent] {
		var events: [VoiceActivityEvent] = []

		switch state {
		case .inactive:
			if probability >= configuration.speechStartThreshold {
				activeFrameCount += 1
			} else {
				activeFrameCount = 0
			}

			if activeFrameCount >= configuration.startTriggerFrames {
				state = .active(probability: probability)
				inactiveFrameCount = 0
				activeFrameCount = 0

				events.append(.speechStarted(probability: probability))

				if configuration.emitSpeechProbability {
					events.append(.speechActive(probability: probability))
				}
			}

		case .active:
			state = .active(probability: probability)

			if configuration.emitSpeechProbability {
				events.append(.speechActive(probability: probability))
			}

			if probability <= configuration.speechEndThreshold {
				inactiveFrameCount += 1
			} else {
				inactiveFrameCount = 0
			}

			if inactiveFrameCount >= configuration.endTriggerFrames {
				state = .inactive
				inactiveFrameCount = 0
				activeFrameCount = 0
				events.append(.speechEnded)
			}
		}

		return events
	}

	public mutating func reset() {
		state = .inactive
		activeFrameCount = 0
		inactiveFrameCount = 0
	}

	public var currentState: VoiceActivityState {
		state
	}
}
