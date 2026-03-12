import Testing
@testable import PhysisVAD

struct VoiceActivityStateMachineTests {
	@Test
	func speechStartsAfterConfiguredFrames() {
		let config = VADConfiguration(
			speechStartThreshold: 0.6,
			speechEndThreshold: 0.35,
			startTriggerFrames: 3,
			endTriggerFrames: 8,
			emitSpeechProbability: false
		)

		var machine = VoiceActivityStateMachine(configuration: config)

		#expect(machine.process(probability: 0.7).isEmpty)
		#expect(machine.process(probability: 0.8).isEmpty)

		let events = machine.process(probability: 0.9)

		#expect(events == [.speechStarted(probability: 0.9)])
		#expect(machine.currentState.isActive)
	}

	@Test
	func speechEndsAfterConfiguredFrames() {
		let config = VADConfiguration(
			speechStartThreshold: 0.6,
			speechEndThreshold: 0.35,
			startTriggerFrames: 1,
			endTriggerFrames: 3,
			emitSpeechProbability: false
		)

		var machine = VoiceActivityStateMachine(configuration: config)

		_ = machine.process(probability: 0.95)
		#expect(machine.currentState.isActive)

		_ = machine.process(probability: 0.1)
		_ = machine.process(probability: 0.1)
		let events = machine.process(probability: 0.1)

		#expect(events.contains(.speechEnded))
		#expect(!machine.currentState.isActive)
	}
}
