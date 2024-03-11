//
//  GameState.swift
//  TicTacToeMultipeerApp
//
//  Created by Abdullah Ajmal on 2024-02-24.
//

import SwiftUI

enum Tile {
    case nought
    case cross
    case empty
    
    var displayTitle: String {
        switch self {
        case .nought:
            return "circle"
        case .cross:
            return "plus"
        case .empty:
            return ""
        }
    }
    var displayTitle1: String {
        switch self {
        case .nought:
            return "O"
        case .cross:
            return "X"
        case .empty:
            return ""
        }
    }
    
    var tileColor: Color {
        switch self {
        case .nought:
            return Color(.nought)
        case .cross:
            return Color(.cross)
        case .empty:
            return Color(.black) // Color doens't matter here
        }
    }
}

class GameState: ObservableObject {
    // Board is a 3x3 2D array of type Tile -> This array stores .cross, .nought or .empty
    @Published var board: [[Tile]]     = Array(repeating: Array(repeating: .empty, count: 3), count: 3)
    @Published var currentPlayer: Tile = .cross
    @Published var count               = 0
    
    @Published var gameStateText       = ""
    
    @Published var noughtScore         = 0
    @Published var crossScore          = 0
    
    @Published var isGameOver          = false
    
    @Published var isSettingsViewPresented = false
    
    
    func cellTapped(row: Int, column: Int, isMyTurn: Bool) {
        if !isGameOver { // If game is not over, then proceed
            
            guard board[row][column] == .empty else { return } // Only if board[row][column] is empty it will go thru
            
            // Place the tile
            board[row][column] = currentPlayer == .cross ? .cross : .nought
            
            // Check for win
            if checkForWin() {
                isGameOver = true
                count = 0
                
                if isMyTurn {
                    gameStateText = "You Win!"
                } else {
                    gameStateText = "You Lose!"
                }
                
                if currentPlayer == .cross {
                    crossScore += 1
                } else {
                    noughtScore += 1
                }
                
            } else if isBoardFull() {
                gameStateText = "It's a draw"
                
            } else {
                // Switch to the other player
                currentPlayer = currentPlayer == .cross ? .nought : .cross
            }
        }
    }
    
    func checkForWin() -> Bool {
        // Check rows
        for row in 0...2 {
            if board[row][0] == currentPlayer &&
                board[row][1] == currentPlayer &&
                board[row][2] == currentPlayer {
                return true
            }
        }
        
        // Check columns
        for column in 0...2 {
            if board[0][column] == currentPlayer &&
                board[1][column] == currentPlayer &&
                board[2][column] == currentPlayer {
                return true
            }
        }
        
        // Check diagonals
        if board[0][0] == currentPlayer &&
            board[1][1] == currentPlayer &&
            board[2][2] == currentPlayer {
            return true
        }
        if board[0][2] == currentPlayer &&
            board[1][1] == currentPlayer &&
            board[2][0] == currentPlayer {
            return true
        }
        
        return false
    }
    
    func isBoardFull() -> Bool {
        count += 1
        if count == 9 {
            isGameOver = true
            count = 0
            return true
            
        } else {
            return false
        }
    }
    
    func resetScores() {
        noughtScore = 0
        crossScore  = 0
        
        resetGame()
    }
    
    
    func resetGame() {
        board         = Array(repeating: Array(repeating: .empty, count: 3), count: 3)
        currentPlayer = .cross
        
        gameStateText = ""
        count         = 0
        isGameOver    = false
    }
}
