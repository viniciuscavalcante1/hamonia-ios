//
//  CoachView.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 30/08/2025.
//

import SwiftUI

struct CoachView: View {
    @StateObject private var viewModel = CoachViewModel()
    
    var body: some View {
        VStack {
            // Mensagens
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) {
                    // Scroll
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Coach digitando
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .padding(.leading)
                    Text("Coach IA está digitando...")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            // Input
            HStack {
                TextField("Pergunte algo ao Coach IA...", text: $viewModel.userMessage, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5)
                
                Button(action: viewModel.sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                }
                .disabled(viewModel.userMessage.isEmpty || viewModel.isLoading)
            }
            .padding()
        }
        .navigationTitle("Coach IA")
    }
}


struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.content)
                .padding(12)
                .background(message.isUser ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundColor(message.isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}


struct CoachView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CoachView()
        }
    }
}
