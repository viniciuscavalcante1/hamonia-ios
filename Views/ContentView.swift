//
//  ContentView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 30/08/2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    // Propriedades AppStorage
    @AppStorage("isUserAuthenticated") private var isUserAuthenticated: Bool = false
    
    var body: some View {
        Group {
            if isUserAuthenticated {
                AppTabView()
            } else {
                LoginView()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                print("App ficou ativo!")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

