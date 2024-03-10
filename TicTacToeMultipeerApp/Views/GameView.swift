//
//  GameView.swift
//  TicTacToeMultipeerApp
//
//  Created by Abdullah Ajmal on 2024-02-22.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: DeviceFinderViewModel
    
    var body: some View {
        ZStack {
            Color(.bg)
                .ignoresSafeArea()
            
            ZStack {
                PlayerListView(viewModel: viewModel)
                    .offset(y: viewModel.isPaired ? -200 : 0)
                    .opacity(viewModel.isPaired ? 0 : 1)
                
                TicTacToeGameView(viewModel: viewModel)
                    .offset(y: viewModel.isPaired ? 0 : 200)
                    .opacity(viewModel.isPaired ? 1 : 0)
            }
        }
        .animation(.easeInOut, value: viewModel.isPaired)
    }
}

#Preview {
    GameView(viewModel: DeviceFinderViewModel())
}


struct PlayerListView: View {
    @ObservedObject var viewModel: DeviceFinderViewModel
    
    var body: some View {
        ZStack {
            Color(.bg)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                List(viewModel.peers) { peer in
                    HStack(spacing: 15) {
                        Image(systemName: "person.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color(.bg))
                        
                        Text(peer.peerId.displayName)
                            .foregroundStyle(Color(.bg))
                        
                        Spacer()
                    }
                    .onTapGesture {
                        viewModel.selectedPeer = peer
                    }
                    .padding(.vertical, 5)
                    .listRowBackground(Color.black)
                }
                .scrollContentBackground(.hidden)
                
                VStack(spacing: 10) {
                    ProgressView()
                    
                    Text("Looking for players...")
                }
                .padding(.vertical)
                    
            }
            .onAppear {
                viewModel.startBrowsing()
            }
            .onDisappear {
                viewModel.stopBrowsing()
            }
            .alert("Connection Request", isPresented: $viewModel.receivedInvite, presenting: viewModel.permissionRequest, actions: { request in
                
                Button("Yes", role: .destructive) {
                    request.onRequest(true)
                    viewModel.show(peerId: request.peerId)
                }
                Button("No", role: .cancel) {
                    request.onRequest(false)
                }
            }, message: { request in
                Text("Do you want to connect with \(request.peerId.displayName)?")
            })
        }
    }
}
