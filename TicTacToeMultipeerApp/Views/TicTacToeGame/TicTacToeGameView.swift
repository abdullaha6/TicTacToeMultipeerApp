//
//  TicTacToeGameView.swift
//  TicTacToeMultipeerApp
//
//  Created by Abdullah Ajmal on 2024-02-29.
//

import SwiftUI

struct TicTacToeGameView: View {
    @StateObject var gameState   = GameState()
    @ObservedObject var viewModel: DeviceFinderViewModel
    
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
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    })
                }
                
                Spacer()
                
                // GAME STATE TEXT
                if gameState.gameStateText.isEmpty {
                    // GAME STATE TEXT
                    Text(viewModel.isMyTurn ? "Your Turn" : "Opponent's Turn")
                        .frame(height: 30)
                        .bold()
                        .padding(.bottom, 30)
                } else {
                    // GAME STATE TEXT
                    Text(gameState.gameStateText)
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
                                
                                Image(systemName: cell.displayTitle)
                                    .rotationEffect(.degrees(45))
                                    .foregroundStyle(cell.tileColor)
                                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                                    .background(Color(.bg))
                                    .onTapGesture {
                                        if viewModel.isMyTurn {
                                            gameState.cellTapped(row: row, column: column)
                                            viewModel.send(isConnected: true, isGameReset: false, row: row, col: column)
                                        }
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
                .onAppear {
                    viewModel.onReceived = { isPeerConnected, isGameReset, row, col in
                        if isPeerConnected {
                            if isGameReset == true {
                                gameState.resetGame()
                            } else {
                                gameState.cellTapped(row: row, column: col)
                            }
                        } else {
                            gameState.resetScores()
                            print("Show opponent disconnected alert")
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
                
                
                // RESET BUTTON
                Button(action: {
                    gameState.resetGame()
                    viewModel.send(isConnected: true, isGameReset: true, row: 0, col: 0)
                }, label: {
                    TextButton(title: "Reset Game")
                        .foregroundStyle(.background)
                })
                .opacity(gameState.isGameOver ? 1 : 0)
                
                Spacer()
            }
            .padding(30)
            .sheet(isPresented: $gameState.isSettingsViewPresented) {
                SettingsView(gameState: gameState, viewModel: viewModel)
            }
        }
    }
}

#Preview {
    TicTacToeGameView(viewModel: DeviceFinderViewModel())
}
