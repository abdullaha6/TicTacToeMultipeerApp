//
//  TicTacToeGameView.swift
//  TicTacToeMultipeerApp
//
//  Created by Abdullah Ajmal on 2024-02-29.
//

import SwiftUI

struct TicTacToeGameView: View {
    @StateObject var gameState   = GameState()
    @ObservedObject var DFViewModel: DeviceFinderViewModel
    
    var body: some View {
        ZStack {
            Color(.bg)
                .ignoresSafeArea()
            VStack {
                // RESET BUTTON
                HStack {
                    Spacer()
                    
                    Button(action: {
                        gameState.isSettingsViewPresented = true
                    }, label: {
                        Image(systemName: "gear")
                            .padding(10)
                            .foregroundStyle(.background)
                            .background(Color(.bgInverse))
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    })
                }
                
                Spacer()
                
                // GAME STATE TEXT
                if gameState.gameStateText.isEmpty {
                    // GAME STATE TEXT
                    Text(DFViewModel.isMyTurn ? "Your Turn" : "Opponent's Turn")
                        .foregroundStyle(Color(.bgInverse))
                        .frame(height: 30)
                        .bold()
                        .padding(.bottom, 30)
                } else {
                    // GAME STATE TEXT
                    Text(gameState.gameStateText)
                        .foregroundStyle(Color(.bgInverse))
                        .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 30))
                        .frame(height: 30)
                        .bold()
                        .padding(.bottom, 30)
                }
                
                
                // GAME
                VStack(spacing: 1) {
                    // GRID
                    ForEach(0...2, id: \.self) { row in
                        
                        HStack(spacing: 1) {
                            ForEach(0...2, id: \.self) { column in
                                
                                let cell = gameState.board[row][column]
                                
                                Group { // Using Group to avoid to avoid code duplication
                                    if cell == .empty {
                                        Text(cell.displayTitle1)
                                    } else {
                                        Image(systemName: cell.displayTitle)
                                            .rotationEffect(.degrees(45))
                                            .foregroundStyle(cell.tileColor)
                                            .font(.system(size: 40, weight: .semibold, design: .rounded))
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .background(Color(.bg))
                                .onTapGesture {
                                    makeMove(row: row, column: column)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    onReceivedMove()
                }
                .background(Color(.bgInverse))
                .border(Color(.bgInverse), width: 1)
                .padding(.horizontal, 20)
                
                HStack {
                    VStack(spacing: 0) {
                        Text("Cross")
                            .foregroundStyle(Color(.bgInverse))
                            .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 20))
                        
                        Text("\(gameState.crossScore)")
                            .foregroundStyle(Color(.bgInverse))
                            .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 40))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Text("Nought")
                            .foregroundStyle(Color(.bgInverse))
                            .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 20))
                        
                        Text("\(gameState.noughtScore)")
                            .foregroundStyle(Color(.bgInverse))
                            .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 40))
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                
                // RESET BUTTON
                Button(action: {
                    gameState.resetGame()
                    DFViewModel.send(isConnected: true, isGameReset: true, row: 0, col: 0)
                }, label: {
                    TextButton(title: "Reset Game")
                        .foregroundStyle(Color(.bg))
                })
                .opacity(gameState.isGameOver ? 1 : 0)
                
                Spacer()
            }
            .padding(30)
            .sheet(isPresented: $gameState.isSettingsViewPresented) {
                SettingsView(gameState: gameState, viewModel: DFViewModel)
            }
        }
    }
    
    func makeMove(row: Int, column: Int) {
        if DFViewModel.isMyTurn {
            gameState.cellTapped(row: row, column: column, isMyTurn: true)
            DFViewModel.send(isConnected: true, isGameReset: false, row: row, col: column)
        }
    }
    
    func onReceivedMove() {
        DFViewModel.onReceived = { isPeerConnected, isGameReset, row, col in
            if isPeerConnected {
                if isGameReset == true {
                    gameState.resetGame()
                } else {
                    gameState.cellTapped(row: row, column: col, isMyTurn: false)
                }
            } else {
                gameState.resetScores()
                print("Show opponent disconnected alert")
            }
        }
    }
}

#Preview {
    TicTacToeGameView(DFViewModel: DeviceFinderViewModel())
}
