//
//  AppTabView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 30/08/2025.
//

import SwiftUI

struct AppTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
            MentalWellnessView()
                .tabItem {
                    Label("Mente", systemImage: "brain.head.profile")
                }
            CoachView()
                .tabItem {
                    Label("Coach", systemImage: "sparkles")
                }
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
