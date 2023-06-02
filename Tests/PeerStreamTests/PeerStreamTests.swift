import XCTest
import PeerStream
import MultipeerConnectivity

final class PeerStreamTests: XCTestCase {
    func testInit() throws {
        #if os(macOS)
        let myPeerId = MCPeerID(displayName: Host.current().localizedName!)
        #else
        let myPeerId = MCPeerID(displayName: UIDevice.current.name)
        #endif
        let peerStream = PeerStream(serviceType: "test-service", peerID: myPeerId)
    }
}
