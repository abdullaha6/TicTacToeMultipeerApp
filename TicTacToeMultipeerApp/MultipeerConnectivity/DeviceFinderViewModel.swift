//
//  DeviceFinderViewModel.swift
//  TicTacToeMultipeerApp
//
//  Created by Abdullah Ajmal on 2024-02-27.
//

import MultipeerConnectivity
import SwiftUI

class DeviceFinderViewModel: ObservableObject {
    private let advertiser  : MCNearbyServiceAdvertiser
    private let session     : MCSession
    private let serviceType = "nearby-devices"
    
    @Published var isAdvertised: Bool = false {
        didSet {
            isAdvertised ? advertiser.startAdvertisingPeer() : advertiser.stopAdvertisingPeer()
        }
    }
    
    init() {
        let peer = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peer)
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: peer,
            discoveryInfo: nil,
            serviceType: serviceType
        )
    }
}
