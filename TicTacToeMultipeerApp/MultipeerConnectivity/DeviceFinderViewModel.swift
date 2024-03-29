//
//  DeviceFinderViewModel.swift
//  TicTacToeMultipeerApp
//
//  Created by Abdullah Ajmal on 2024-02-27.
//

import MultipeerConnectivity
import SwiftUI

class DeviceFinderViewModel: NSObject, ObservableObject {
    private let advertiser  : MCNearbyServiceAdvertiser
    private let browser     : MCNearbyServiceBrowser
    private let session     : MCSession
    private let serviceType = "TicTacToe"
    
    var onReceived: ((Bool, Bool, Int, Int) -> Void)?
    
    @Published var peers: [PeerDevice] = [] // To store the available peers
    @Published var permissionRequest: PermitionRequest?
    
    @Published var isMyTurn       = false // Bool to store which player goes first
        
    @Published var receivedInvite = false
    @Published var selectedPeer: PeerDevice? {
        didSet {
            connect()
        }
    }
    @Published var isPaired                 = false
    @Published var joinedPeer: [PeerDevice] = []
    
    @Published var playerListView    = false
    @Published var showTicTacToeView = false
    
    @Published var isAdvertised = false {
        didSet {
            isAdvertised ? advertiser.startAdvertisingPeer() : advertiser.stopAdvertisingPeer()
        }
    }
    
    override init() {
        let peer = MCPeerID(displayName: UIDevice.current.name)
        session  = MCSession(peer: peer)
        
        advertiser = MCNearbyServiceAdvertiser(
            peer         : peer,
            discoveryInfo: nil,
            serviceType  : serviceType
        )
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        
        super.init()
        
        browser.delegate    = self
        advertiser.delegate = self
        session.delegate    = self
    }
    
    deinit {
        stopBrowsing()
        advertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        browser.stopBrowsingForPeers()
        peers.removeAll()
    }
    
    func disconnect() {
        session.disconnect()
    }
    
    func show(peerId: MCPeerID) {
        guard let first = peers.first(where: { $0.peerId == peerId }) else {
            return
        }
        joinedPeer.append(first)
    }
    
    private func connect() {
        guard let selectedPeer else {
            return
        }
        
        if session.connectedPeers.contains(selectedPeer.peerId) {
            joinedPeer.append(selectedPeer)
            
        } else {
            let randomBool = Bool.random()
            self.isMyTurn  = !randomBool // Opposite of the bool being sent to the connecting device
            
            if randomBool {
                let contextData = "0"
                browser.invitePeer(selectedPeer.peerId, to: session, withContext: contextData.data(using: .utf8), timeout: 60)
            } else {
                let contextData = "1"
                browser.invitePeer(selectedPeer.peerId, to: session, withContext: contextData.data(using: .utf8), timeout: 60)
            }
        }
    }
    
    func send(isConnected: Bool, isGameReset: Bool, row: Int, col: Int) {

        let dataToSend = GameData(isPeerConnected: isConnected, isGameReset: isGameReset, isGameRestarted: false, row: row, col: col)
        isMyTurn = !isMyTurn
        
        if !session.connectedPeers.isEmpty {
            do {
                let jsonData = try JSONEncoder().encode(dataToSend)
                try session.send(jsonData, toPeers: session.connectedPeers, with: .reliable)
                
            } catch {
                print("Failed to send data with error: \(error.localizedDescription)")
            }
        }
    }
}

extension DeviceFinderViewModel: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // The browsing happens in a background thread, so you need to go back to the main queue and append to the array
        DispatchQueue.main.async {
            self.peers.append(PeerDevice(peerId: peerID)) // Peer found, add to the peers array
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.peers.removeAll(where: { $0.peerId == peerID }) // Peer lost, remove from the peers array
        }
    }
}

extension DeviceFinderViewModel: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        DispatchQueue.main.async {
            self.receivedInvite    = true
            if let receivedContext = context,
               let contextString   = String(data: receivedContext, encoding: .utf8) {
                
                if contextString == "0" {
                    self.isMyTurn = true
                } else {
                    self.isMyTurn = false
                }
            }
            self.permissionRequest = PermitionRequest(
                peerId   : peerID,
                onRequest: { [weak self] permission in
                    invitationHandler(permission, permission ? self?.session : nil)
                }
            )
        }
    }
}

extension DeviceFinderViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async {
                self.isPaired = false
            }
        case .connecting:
            print("Connecting")
            
        case .connected:
            DispatchQueue.main.async {
                self.isPaired = true
            }
        default:
            DispatchQueue.main.async {
                self.isPaired = false
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            do {
                let receivedData = try JSONDecoder().decode(GameData.self, from: data)

                let row             = receivedData.row
                let col             = receivedData.col
                let isConnected     = receivedData.isPeerConnected
                let isGameReset     = receivedData.isGameReset
                
                if isConnected {
                    self.isMyTurn = !self.isMyTurn
                    if let onReceived = self.onReceived {
                        onReceived(isConnected, isGameReset, row, col) // If connected, proceed
                    }
                } else {
                    if let onReceived = self.onReceived {
                        onReceived(isConnected, isGameReset, row, col)
                    }
                    session.disconnect()
                }
                
            } catch {
                print("Error decoding data: \(error)")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    
}

struct PeerDevice: Identifiable, Hashable {
    let id    = UUID()
    let peerId: MCPeerID
}

struct PermitionRequest: Identifiable {
    let id = UUID()
    let peerId: MCPeerID
    let onRequest: (Bool) -> Void
}

struct GameData: Codable {
    let isPeerConnected: Bool
    let isGameReset    : Bool
    let isGameRestarted: Bool
    let row            : Int
    let col            : Int
}
