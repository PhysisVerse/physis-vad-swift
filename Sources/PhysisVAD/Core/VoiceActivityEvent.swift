import Foundation

public enum VoiceActivityEvent: Sendable, Equatable {
	case speechStarted(probability: Float)
	case speechEnded
	case speechActive(probability: Float)
}
