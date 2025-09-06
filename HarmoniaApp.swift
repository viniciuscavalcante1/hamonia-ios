//
//  HarmoniaApp.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 30/08/2025.
//

//
//  HarmoniaApp.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 30/08/2025.
//

import SwiftUI

@main
struct HarmoniaApp: App {
    @AppStorage("isUserAuthenticated") private var isUserAuthenticated: Bool = false
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @State private var isSplashScreenActive: Bool = true

    var body: some Scene {
        WindowGroup {
            Group {
                if isSplashScreenActive {
                    SplashScreenView(isActive: $isSplashScreenActive)
                } else if isUserAuthenticated {
                    if hasCompletedOnboarding {
                        AppTabView()
                    }
                    else {
                        OnboardingView()
                    }
                } else {
                    LoginView()
                }
            }
        }
    }
}
