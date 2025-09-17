//
//  NutritionView.swift
//  Harmonia
//
//  Created by Vinícius de Abreu Cavalcante on 15/09/25.
//

import SwiftUI

struct NutritionView: View {
    @StateObject private var viewModel = NutritionViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if let image = viewModel.selectedImage {
                    AnalysisStepsView(image: image, viewModel: viewModel)
                } else {
                    InitialPromptView(viewModel: viewModel)
                }
            }
            .navigationTitle("Refeição")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.isShowingImagePicker) {
                ImagePicker(image: $viewModel.selectedImage, sourceType: viewModel.imagePickerSourceType)
            }
            .alert("Sucesso!", isPresented: $viewModel.isShowingSuccessAlert) {
                Button("OK", role: .cancel) {
                    viewModel.reset()
                }
            } message: {
                Text("Sua refeição foi registrada com sucesso.")
            }
        }
    }
}


private struct InitialPromptView: View {
    @ObservedObject var viewModel: NutritionViewModel
    
    var body: some View {
        VStack {
            Spacer()
            ContentUnavailableView(
                "Registre sua refeição",
                systemImage: "camera.viewfinder",
                description: Text("Tire uma foto ou escolha uma imagem da sua galeria pra gente analisar!")
            )
            Spacer()
            
            HStack(spacing: 20) {
                Button {
                    viewModel.imagePickerSourceType = .camera
                    viewModel.isShowingImagePicker = true
                } label: {
                    Label("Tirar foto", systemImage: "camera.fill")
                }
                
                Button {
                    viewModel.imagePickerSourceType = .photoLibrary
                    viewModel.isShowingImagePicker = true
                } label: {
                    Label("Galeria", systemImage: "photo.on.rectangle.angled")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.bottom, 30)
        }
    }
}

private struct AnalysisStepsView: View {
    let image: UIImage
    @ObservedObject var viewModel: NutritionViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Analisando sua refeição...")
                    .padding()
            } else if let result = viewModel.analysisResult {
                AnalysisResultView(result: result, image: image, viewModel: viewModel)
            } else if let error = viewModel.errorMessage {
                VStack {
                    ContentUnavailableView("Ocorreu um erro", systemImage: "exclamationmark.triangle", description: Text(error))
                    Button("Tentar novamente") {
                        viewModel.analyzeImage()
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .padding()
                
                Button(action: {
                    viewModel.analyzeImage()
                }) {
                    Label("Analisar", systemImage: "sparkles")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Escolher outra foto", role: .cancel) {
                    viewModel.reset()
                }
                .padding(.top)
            }
        }
    }
}

private struct AnalysisResultView: View {
    let result: NutritionAnalysisResponse
    let image: UIImage
    @ObservedObject var viewModel: NutritionViewModel
    
    var body: some View {
        List {
            Section {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.vertical, 8)
            }
            
            Section(header: Text("Insights")) {
                Text(result.insights)
                    .foregroundStyle(.secondary)
            }
            
            Section(header: Text("Total estimado")) {
                Text("\(result.totalCalories, specifier: "%.0f") kcal")
                    .font(.title2.bold())
            }
            
            Section(header: Text("Alimentos identificados")) {
                ForEach(result.foods) { food in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(food.foodName).font(.headline)
                        HStack {
                            Text("Calorias estimadas: \(food.calories, specifier: "%.0f")")
                            Spacer()
                            Text("P: \(food.protein, specifier: "%.0f")g")
                            Text("C: \(food.carbs, specifier: "%.0f")g")
                            Text("G: \(food.fat, specifier: "%.0f")g")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section {
                Button(action: {
                    viewModel.saveLog()
                }) {
                    Label("Confirmar e salvar", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                
                Button("Descartar analisar outra", role: .destructive, action: {
                    viewModel.reset()
                })
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .listRowBackground(Color.clear)
        }
    }
}


struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
    }
}
