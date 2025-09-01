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

struct CoachRequest: Codable {
    let text: String
    let userId: Int
}

struct CoachResponse: Codable {
    let answer: String
}

// MARK: Network Service
class NetworkService {
    
    /// Instância compartilhada de NetworkService
    static let shared = NetworkService()
    
    /// URL base da API no GCP Cloud Run =)
    private let baseURL = URL(string: "https://harmonia-api-378861620628.us-central1.run.app/")!

    private init() {}
    
    /// Converte snake para camel
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
    
    /// Login e cadastrno no back
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

    /// Envia request para o endpoint de coach
    func askCoach(prompt: String, userId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/coach/ask")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody = CoachRequest(text: prompt, userId: userId)
        
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
                    let coachResponse = try self.createDecoder().decode(CoachResponse.self, from: data)
                    completion(.success(coachResponse.answer))
                } catch {
                    print("Erro ao enviar mensagem ao endpoint ask_coach: \(error)"); completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Busca dados para montar o dashboard
    func fetchDashboardData(userId: Int, completion: @escaping (Result<DashboardDataResponse, Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())

        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("/dashboard/user/\(userId)"), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [ URLQueryItem(name: "date_str", value: todayString) ]
        
        guard let url = urlComponents?.url else {
            completion(.failure(URLError(.badURL))); return
        }
        
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
}
