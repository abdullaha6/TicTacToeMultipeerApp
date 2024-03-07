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
            
            
            if !viewModel.isPaired {
                PlayerListView(viewModel: viewModel)
                
            } else {
                TicTacToeGameView()
            }
        }
    }
}

#Preview {
    GameView(viewModel: DeviceFinderViewModel())
}

struct SettingsView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                gameState.resetGame()
                gameState.showSheet = false
            }, label: {
                TextButton(title: "Reset Game", isInverse: true)
                    .foregroundStyle(.foreground)
            })
            
            Button(action: {
                gameState.resetScores()
                gameState.showSheet = false
            }, label: {
                TextButton(title: "Restart Game", isInverse: true)
                    .foregroundStyle(.foreground)
            })
        }
        .presentationDetents([.height(200)])
//        .presentationBackgroundInteraction(.enabled(upThrough: .height(10)))
        .presentationCornerRadius(15)
        .presentationBackground(.foreground)
    }
}

struct PlayerListView: View {
    @ObservedObject var viewModel: DeviceFinderViewModel
    
    var body: some View {
        ZStack {
            Color(.bg)
                .ignoresSafeArea()
            
            List(viewModel.peers) { peer in
                HStack(spacing: 15) {
                    Image(systemName: "person")
                        .imageScale(.large)
                        .foregroundStyle(.foreground)
                    
                    Text(peer.peerId.displayName)
                        .foregroundStyle(.foreground)
                    
                    Spacer()
                    
                    if viewModel.isPaired {
                        Image(systemName: "checkmark.circle")
                            .imageScale(.medium)
                            .foregroundStyle(.green)
                    }
                }
                .onTapGesture {
                    viewModel.selectedPeer = peer
                }
                .padding(.vertical, 5)
                .listRowBackground(Color(.bg))
            }
            .scrollContentBackground(.hidden)
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
            
            //        .presentationDetents(viewModel.isPaired ? [.large] : [.height(200)])
            //        .presentationCornerRadius(15)
            //        .presentationBackground(.foreground)
        }
    }
}

struct TextButton: View {
    let title    : String
    var isInverse: Bool = false
    
    var body: some View {
        Text(title)
//            .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 20))
            .multilineTextAlignment(.center)
            .tracking(2)
            .padding(.vertical, 10)
            .frame(width: 200)
            .background(isInverse ? Color(.bg) : .black)
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

struct TicTacToeGameView: View {
    @StateObject var gameState = GameState()
    
    var body: some View {
        VStack {
            // RESET BUTTON
            HStack {
                Spacer()
                
                Button(action: {
                    gameState.showSheet = true
                }, label: {
                    Image(systemName: "gear")
                        .padding(10)
                        .foregroundStyle(.background)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                })
            }
            
            Spacer()
            
            // GAME STATE TEXT
            Text(gameState.gameStateText)
                .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 30))
                .frame(height: 30)
                .bold()
                .padding(.bottom, 30)
            
            
            // GAME
            VStack(spacing: 1) {
                // GRID
                ForEach(0...2, id: \.self) { row in
                    
                    HStack(spacing: 1) {
                        ForEach(0...2, id: \.self) { column in
                            
                            let cell = gameState.board[row][column]
                            
                            Image(systemName: cell.displayTitle)
                                .rotationEffect(.degrees(45))
                                .foregroundStyle(cell.tileColor)
                                .font(.system(size: 40, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .background(Color(.bg))
                                .onTapGesture {
                                    gameState.cellTapped(row: row, column: column)
                                }
                            
                            //                            Image(systemName: "plus")
                            //                                .rotationEffect(.degrees(45))
                            //                                .foregroundStyle(Color(.cross))
                            //                                .font(.system(size: 50, weight: .semibold, design: .rounded))
                            //                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            //                                .aspectRatio(1, contentMode: .fit)
                            //                                .background(Color(.bg))
                            
                            //                            Text("+")
                            //                                .rotationEffect(.degrees(45))
                            //                                .foregroundStyle(Color(.cross))
                            //                                .font(.system(size: 70, weight: .semibold, design: .rounded))
                            //                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            //                                .aspectRatio(1, contentMode: .fit)
                            //                                .background(Color(.bg))
                        }
                    }
                }
            }
            .background(.foreground)
            .border(.black, width: 1)
            .padding(.horizontal, 20)
            
            HStack {
                VStack(spacing: 0) {
                    Text("Cross")
                        .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 20))
                    
                    Text("\(gameState.crossScore)")
                        .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 40))
                }
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Nought")
                        .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 20))
                    
                    Text("\(gameState.noughtScore)")
                        .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 40))
                    
                }
                
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            
            // RESTART BUTTON
            Button(action: {
                gameState.resetGame()
            }, label: {
                TextButton(title: "Reset Game")
                    .foregroundStyle(.background)
            })
            .opacity(gameState.isGameOver ? 1 : 0)
            
            Spacer()
        }
        .padding(30)
        .sheet(isPresented: $gameState.showSheet) {
            SettingsView(gameState: gameState)
        }
    }
}
