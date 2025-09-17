//
//  NutritionViewModel.swift
//  Harmonia
//
//  Created by Vinícius de Abreu Cavalcante on 15/09/25.
//

import SwiftUI
import Foundation

@MainActor
class NutritionViewModel: ObservableObject {
    
    @Published var selectedImage: UIImage?
    @Published var analysisResult: NutritionAnalysisResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isShowingSuccessAlert = false
    
    @Published var isShowingImagePicker = false
    @Published var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    
    func analyzeImage() {
        guard let image = selectedImage else {
            errorMessage = "Nenhuma imagem selecionada."
            return
        }
        
        isLoading = true
        errorMessage = nil
        analysisResult = nil
        
        NetworkService.shared.analyzeMeal(image: image) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                self?.analysisResult = response
            case .failure(let error):
                self?.errorMessage = "Erro: \(error.localizedDescription)"
            }
        }
    }
    
    func saveLog() {
        guard let result = analysisResult else {
            errorMessage = "Não há análise para salvar."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let foodItems = result.foods.map { food in
            FoodItem(foodName: food.foodName, calories: food.calories, protein: food.protein, carbs: food.carbs, fat: food.fat)
        }
        
        let totalProtein = foodItems.reduce(0) { $0 + $1.protein }
        let totalCarbs = foodItems.reduce(0) { $0 + $1.carbs }
        let totalFat = foodItems.reduce(0) { $0 + $1.fat }
        
        let newLog = NutritionLogCreate(
            userId: 1,
            logDate: Date(),
            totalCalories: result.totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            insights: result.insights,
            items: foodItems
        )
        
        NetworkService.shared.saveNutritionLog(log: newLog) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.isShowingSuccessAlert = true
            case .failure(let error):
                self?.errorMessage = "Erro ao salvar refeição: \(error.localizedDescription)"
            }
        }
    }
    
    func reset() {
        selectedImage = nil
        analysisResult = nil
        errorMessage = nil
        isLoading = false
    }
}
