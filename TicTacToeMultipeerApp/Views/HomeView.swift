//
//  HomeView.swift
//  TicTacToeMultipeerApp
//
//  Created by Abdullah Ajmal on 2024-02-27.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = DeviceFinderViewModel()
    
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
                    
                    Button(action: {
                        viewModel.showTicTacToeView = true
                    }, label: {
                        TextButton(title: "Play With AI")
                            .foregroundStyle(.background)
                    })
                    
                    Button(action: {
                        viewModel.isAdvertised   = true
                        viewModel.playerListView = true
                    }, label: {
                        TextButton(title: "Multiplayer")
                            .foregroundStyle(.background)
                    })
                    
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $viewModel.playerListView)    { GameView(viewModel: viewModel) }
            .fullScreenCover(isPresented: $viewModel.showTicTacToeView) { TicTacToeGameView(DFViewModel: viewModel) }
        }
    }
}

#Preview {
    HomeView()
}
