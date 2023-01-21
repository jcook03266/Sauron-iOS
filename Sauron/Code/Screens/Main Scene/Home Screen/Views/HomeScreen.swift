//
//  HomeScreen.swift
//  Sauron
//
//  Created by Justin Cook on 1/21/23.
//

import SwiftUI

struct HomeScreen: View {
    // MARK: - Observed
    @StateObject var model: HomeScreenViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(model: .init(coordinator: .init()))
    }
}
