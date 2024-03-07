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
                    
                    Text(viewModel.receivedData)
                        .tracking(1)
                        .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 40))
                        .padding(.bottom, 50)
                    
                    Text("Tic Tac Toe")
                        .tracking(1)
                        .font(Font.custom("BodoniSvtyTwoSCITCTT-Book", size: 40))
                    
                    Text("A Classic Game")
                        .tracking(2)
                        .padding(.bottom, 100)
                    
                    Button(action: {
                        viewModel.send(move: "Hello")
                    }, label: {
                        TextButton(title: "Play With AI")
                            .foregroundStyle(.background)
                    })
                    
                    Button(action: {
                        viewModel.isAdvertised = true
                        viewModel.showSheet    = true
                    }, label: {
                        TextButton(title: "Multiplayer")
                            .foregroundStyle(.background)
                    })
                    
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $viewModel.showSheet) { GameView(viewModel: viewModel) }
//            .sheet(isPresented: $viewModel.showSheet) { PlayerListView(viewModel: viewModel) }
        }
    }
}

#Preview {
    HomeView()
}
