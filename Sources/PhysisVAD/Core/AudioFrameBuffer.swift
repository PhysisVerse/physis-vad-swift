import Foundation

public struct AudioFrameBuffer: Sendable {
	private var storage: [Float] = []

	public init() {}

	public mutating func append(_ samples: [Float]) {
		storage.append(contentsOf: samples)
	}

	public mutating func popFrame(frameSize: Int) -> [Float]? {
		guard storage.count >= frameSize else { return nil }

		let frame = Array(storage.prefix(frameSize))
		storage.removeFirst(frameSize)
		return frame
	}

	public mutating func reset() {
		storage.removeAll(keepingCapacity: true)
	}

	public var count: Int {
		storage.count
	}
}
