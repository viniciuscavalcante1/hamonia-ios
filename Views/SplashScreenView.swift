//
//  SplashScreenView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 31/08/2025.
//

//
//  SplashScreenView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 31/08/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isActive: Bool
    
    @State private var iconScale: CGFloat = 0.7
    @State private var showLoadingText: Bool = false

    var body: some View {
        ZStack {
            Color("SplashScreenBackground")
                .edgesIgnoringSafeArea(.all)

            VStack {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(iconScale)

                if showLoadingText {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .padding(.top, 20)
                    Text("Harmonia")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                self.iconScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                 withAnimation(.easeIn(duration: 0.5)) {
                    self.showLoadingText = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.isActive = false
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(isActive: .constant(true))
    }
}
