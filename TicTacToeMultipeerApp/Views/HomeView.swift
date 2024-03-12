//
//  HomeView.swift
//  TicTacToeMultipeerApp
//
//  Created by Abdullah Ajmal on 2024-02-27.
//

import SwiftUI

struct HomeView: View {
    @StateObject var DFViewModel = DeviceFinderViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.bg)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Text("Tic Tac Toe")
                        .tracking(1)
                        .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 40))
//                        .foregroundStyle(.black)
                    
//                    Button(action: {
//                        viewModel.showTicTacToeView = true
//                    }, label: {
//                        TextButton(title: "Play With AI")
//                            .foregroundStyle(.background)
//                    })
                    
                    NavigationLink {
                        TicTacToeGameView(DFViewModel: DFViewModel)
                    } label: {
                        TextButton(title: "Play with AI")
//                            .foregroundStyle(Color(.bg))
                    }
                    .padding(.top, 50)
                    
                    NavigationLink {
                        GameView(viewModel: DFViewModel)
                    } label: {
                        TextButton(title: "Multiplayer")
//                            .foregroundStyle(Color(.bg))
                    }
//                    .padding(.top, 50)

                    
//                    Button(action: {
//                        viewModel.isAdvertised   = true
//                        viewModel.playerListView = true
//                    }, label: {
//                        TextButton(title: "Multiplayer")
//                            .foregroundStyle(.background)
//                    })
                    
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $DFViewModel.playerListView)    { GameView(viewModel: DFViewModel) }
            .onAppear {
                DFViewModel.isAdvertised = false
            }
//            .fullScreenCover(isPresented: $viewModel.showTicTacToeView) { TicTacToeGameView(DFViewModel: viewModel) }
        }
        .tint(.black) // To chagne the color of the back button
    }
}

#Preview {
    HomeView()
}
