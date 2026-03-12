# PhysisVAD

A modular Swift package for local voice activity detection on Apple platforms.

## Current direction

- Local, on-device VAD
- CoreML-backed Silero VAD
- Platform-local detection only
- No STT ownership
- No runtime/session ownership

## Responsibilities

This package is responsible for:

- loading the VAD model
- accepting mono Float audio samples
- chunking audio into model-sized windows
- running inference
- smoothing activity state
- emitting normalized local speech events

This package is not responsible for:

- transcription
- websocket / networking
- turn semantics
- Orb / UI rendering
- PCC state management

## Expected model location

Place the model here:

`Sources/PhysisVAD/Models/silero-vad-unified-v6.0.0.mlpackage`

## Public surface

- `VADProcessor`
- `VADConfiguration`
- `VoiceActivityEvent`
- `VoiceActivityState`

## Notes

The CoreML wrapper uses a generic `MLModel` loader rather than relying on a generated typed class.
This keeps the package cleaner and more portable inside SwiftPM.
