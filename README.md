### PeerStream

A simple wrapper around Multipeer Connectivity using async iterator streams.

```swift
let peerStream: PeerStream = PeerStream()
Task {
    for try await message in peerStream {
        switch message {
        case .onStateChange(state: let state, peer: let peer):
            print("STREAM", state == .connected, peer.displayName)
        default:
            break
        }
    }
}
```
