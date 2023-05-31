import MultipeerConnectivity

enum PeerStreamMessage {
    case onData(
        data: Data,
        peer: MCPeerID
    )
    case onStateChange(
        state: MCSessionState,
        peer: MCPeerID
    )
    case onReceiveInvitation(
        peer: MCPeerID
    )
}

class PeerStream: AsyncSequence {
    typealias Element = PeerStreamMessage
    typealias AsyncIterator = AsyncThrowingStream<PeerStreamMessage, Error>.Iterator

    #if os(macOS)
    private let myPeerId = MCPeerID(displayName: Host.current().localizedName!)
    #else
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    #endif
    
    private var stream: AsyncThrowingStream<Element, Error>?
    private var continuation: AsyncThrowingStream<Element, Error>.Continuation?
    private var session: MCSession
    private var multipeerSession = MultipeerSession()

    init(url: String) {
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
        stream = AsyncThrowingStream { continuation in
            self.continuation = continuation
            self.continuation?.onTermination = { @Sendable [session] _ in
                session.disconnect()
            }
        }
        multipeerSession.continuation = continuation
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        guard let stream = stream else {
            fatalError("stream was not initialized")
        }
        
        return stream.makeAsyncIterator()
    }
    
    func send(data: Data, peers: [MCPeerID], with dataMode: MCSessionSendDataMode = .reliable) throws {
        try session.send(data, toPeers: peers, with: dataMode)
    }
}
