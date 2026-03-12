import Foundation

public enum VoiceActivityState: Sendable, Equatable {
	case inactive
	case active(probability: Float)

	public var isActive: Bool {
		switch self {
		case .inactive:
			false
		case .active:
			true
		}
	}

	public var probability: Float {
		switch self {
		case .inactive:
			0
		case .active(let probability):
			probability
		}
	}
}
