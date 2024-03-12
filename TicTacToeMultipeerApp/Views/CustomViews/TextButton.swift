//
//  TextButton.swift
//  TicTacToeMultipeerApp
//
//  Created by Abdullah Ajmal on 2024-02-29.
//

import SwiftUI

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
            .background(isInverse ? Color(.bg) : Color(.bgInverse))
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

#Preview {
    TextButton(title: "Reset Button")
}
