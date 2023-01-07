//
//  ContentView.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Rectangle()
            .background(Colors.gradient_3)
            .applyGradient(gradient: Colors.gradient_5)
            .frame(width: .infinity,
                   height: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
