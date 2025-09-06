//
//  NetworkService.swift
//  Harmonia
//
//  Created by Vinícius Cavalcante on 01/09/2025.
//

import Foundation

// MARK: Models
// Structs para ler as respostas json da API

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}

struct DashboardDataResponse: Codable {
    let userName: String
    let activity: ActivityData
    let sleep: SleepData
    let dailyInsight: String
    let habits: [Habit]
}

struct ActivityData: Codable {
    let steps: Int
}

struct SleepData: Codable {
    let duration: String
}

struct Habit: Codable, Identifiable {
    let id: Int
    let userId: Int
    let name: String
    let icon: String
    var isCompleted: Bool
    let date: String
}

struct CoachResponse: Codable {
    let answer: String
}

struct ChatMessagePayload: Codable {
    let role: String
    let content: String
}

struct HabitSuggestion: Codable, Identifiable {
    let name: String
    let icon: String
    var id: String { name }
}

struct ErrorResponse: Codable {
    let detail: String
}


// MARK: Network Service
class NetworkService {
    
    /// Instância compartilhada de NetworkService
    static let shared = NetworkService()
    
    /// URL base da API no GCP Cloud Run =)
    private let baseURL = URL(string: "https://harmonia-api-378861620628.us-central1.run.app/")!

    private init() {}
    
    /// Converte snake_case para camelCase
    private func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    /// Struct para o corpo da request de login
    private struct LoginRequest: Codable {
        let name: String
        let email: String
    }
    
    /// Login e cadastro no back
    func login(name: String, email: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/users/login")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody = LoginRequest(name: name, email: email)
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(error)); return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.failure(URLError(.badServerResponse))); return }
                do {
                    let user = try self.createDecoder().decode(User.self, from: data)
                    completion(.success(user))
                } catch {
                    print("Erro ao realizar login(): \(error)"); completion(.failure(error))
                }
            }
        }.resume()
    }

    /// Envia request para o endpoint de coach, incluindo o histórico da conversa.
    func askCoach(currentMessage: String, history: [ChatMessagePayload], userId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/coach/ask")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "current_message": currentMessage,
            "history": history.map { ["role": $0.role, "content": $0.content] },
            "user_id": userId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(error)); return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.failure(URLError(.badServerResponse))); return }
                
                do {
                    let coachResponse = try self.createDecoder().decode(CoachResponse.self, from: data)
                    completion(.success(coachResponse.answer))
                } catch {
                    do {
                        let errorResponse = try self.createDecoder().decode(ErrorResponse.self, from: data)
                        let customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorResponse.detail])
                        completion(.failure(customError))
                    } catch let decodingError {
                        print("Erro ao decodificar tanto CoachResponse quanto ErrorResponse: \(decodingError)")
                        completion(.failure(decodingError))
                    }
                }
            }
        }.resume()
    }
    
    /// Busca dados para montar o dashboard
    func fetchDashboardData(userId: Int, completion: @escaping (Result<DashboardDataResponse, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/dashboard/user/\(userId)")
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.failure(URLError(.badServerResponse))); return }
                do {
                    let dashboardResponse = try self.createDecoder().decode(DashboardDataResponse.self, from: data)
                    completion(.success(dashboardResponse))
                } catch {
                    print("Erro ao montar dashboard: \(error)"); completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Toggle habit backend
    func toggleHabitCompletion(habit: Habit, completion: @escaping (Result<Habit, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/habits/\(habit.id)/toggle")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.failure(URLError(.badServerResponse))); return }
                do {
                    let updatedHabit = try self.createDecoder().decode(Habit.self, from: data)
                    completion(.success(updatedHabit))
                } catch {
                    print("Erro em toggleHabitCompletion(): \(error)"); completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Busca dados de usuário para montar perfil
    func fetchUserDetails(userId: Int, completion: @escaping (Result<User, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/users/\(userId)")
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.failure(URLError(.badServerResponse))); return }
                do {
                    let user = try self.createDecoder().decode(User.self, from: data)
                    completion(.success(user))
                } catch {
                    print("Erro em fetchUserDetails(): \(error)"); completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Cria um novo hábito para um usuário
    func addHabit(userId: Int, name: String, icon: String, completion: @escaping (Result<Habit, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/users/\(userId)/habits")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: String] = ["name": name, "icon": icon]
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(error)); return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.failure(URLError(.badServerResponse))); return }
                do {
                    let newHabit = try self.createDecoder().decode(Habit.self, from: data)
                    completion(.success(newHabit))
                } catch {
                    print("Erro em addHabit(): \(error)"); completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Salva o objetivo principal do usuário no backend
    func updateUserGoal(goal: String, userId: Int, completion: @escaping (Result<User, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/users/\(userId)")
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["main_goal": goal]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error)); return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.failure(URLError(.badServerResponse))); return }
                do {
                    let updatedUser = try self.createDecoder().decode(User.self, from: data)
                    completion(.success(updatedUser))
                } catch {
                    print("Erro em updateUserGoal(): \(error)"); completion(.failure(error))
                }
            }
        }.resume()
    }

    /// Busca sugestões de hábitos com base em um objetivo
    func fetchSuggestedHabits(for objective: String, completion: @escaping (Result<[HabitSuggestion], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/onboarding/suggest-habits")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["objective": objective]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error)); return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.failure(URLError(.badServerResponse))); return }
                do {
                    let suggestions = try self.createDecoder().decode([HabitSuggestion].self, from: data)
                    completion(.success(suggestions))
                } catch {
                    print("Erro em fetchSuggestedHabits(): \(error)"); completion(.failure(error))
                }
            }
        }.resume()
    }
}
