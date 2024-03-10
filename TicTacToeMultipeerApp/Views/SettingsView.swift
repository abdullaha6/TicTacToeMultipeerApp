//
//  SettingsView.swift
//  TicTacToeMultipeerApp
//
//  Created by Abdullah Ajmal on 2024-03-08.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject var viewModel: DeviceFinderViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                gameState.resetGame()
                gameState.isSettingsViewPresented = false
            }, label: {
                TextButton(title: "Reset Game", isInverse: true)
                    .foregroundStyle(.foreground)
            })
            
            Button(action: {
                gameState.resetScores()
                gameState.isSettingsViewPresented = false
            }, label: {
                TextButton(title: "Restart Game", isInverse: true)
                    .foregroundStyle(.foreground)
            })
            
            Button(action: {
                gameState.isSettingsViewPresented = false
                gameState.resetScores()
                viewModel.send(isConnected: false, isGameReset: false, row: 0, col: 0)
//                viewModel.disconnect()
            }, label: {
                TextButton(title: "Disconnect", isInverse: true)
                    .foregroundStyle(.foreground)
            })
        }
        .presentationDetents([.height(200)])
        .presentationCornerRadius(15)
        .presentationBackground(.foreground)
    }
}

//#Preview {
//    SettingsView()
//}
