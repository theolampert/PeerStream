import MultipeerConnectivity


public enum PeerStreamMessage {
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
    case onLostPeer(
        peer: MCPeerID
    )
}

public final class PeerStream: AsyncSequence {
    public typealias Element = PeerStreamMessage
    public typealias AsyncIterator = AsyncThrowingStream<PeerStreamMessage, Error>.Iterator
    
    private var stream: AsyncThrowingStream<Element, Error>?
    private var continuation: AsyncThrowingStream<Element, Error>.Continuation?
    private var session: MCSession
    private var multipeerSession: MultipeerSession

    public init(
        serviceType: String,
        peerID: MCPeerID
    ) {
        multipeerSession = MultipeerSession(serviceType: serviceType, peerID: peerID)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        stream = AsyncThrowingStream { continuation in
            self.continuation = continuation
            self.continuation?.onTermination = { @Sendable [session] _ in
                session.disconnect()
            }
        }
        multipeerSession.continuation = continuation
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        guard let stream = stream else {
            fatalError("stream was not initialized")
        }
        
        return stream.makeAsyncIterator()
    }
    
    public func send(
        data: Data,
        peers: [MCPeerID],
        with dataMode: MCSessionSendDataMode = .reliable
    ) throws {
        try session.send(data, toPeers: peers, with: dataMode)
    }
}
