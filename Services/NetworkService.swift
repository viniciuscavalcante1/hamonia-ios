import Foundation
import UIKit


// MARK: - Models

struct NutritionAnalysisResponse: Codable {
    let foods: [FoodItem]
    let insights: String
    let totalCalories: Double
}

struct FoodItem: Codable, Identifiable {
    let id = UUID()
    let foodName: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    
    enum CodingKeys: String, CodingKey {
        case foodName
        case calories
        case protein
        case carbs
        case fat
    }
}

struct NutritionLogCreate: Codable {
    let userId: Int
    let logDate: Date
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let insights: String?
    let items: [FoodItem]
}
    
struct JournalEntry: Codable, Identifiable {
    let id: Int
    let userId: Int
    let date: Date
    let mood: String
    let text: String

    enum CodingKeys: String, CodingKey {
        case id, userId, date, mood
        case text = "content"
    }
}

struct HabitStatus: Codable, Identifiable {
    let id: Int
    let userId: Int
    let name: String
    let icon: String
    var isCompleted: Bool
}

struct HabitHistoryResponse: Codable {
    let currentStreak: Int
    let completedDates: [String]
}

struct HabitSuggestion: Codable, Identifiable {
    let name: String
    let icon: String
    var id: String { name }
}

struct ErrorResponse: Codable {
    let detail: String
}

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
    let habits: [HabitStatus]
}

struct ActivityData: Codable {
    let steps: Int
}

struct SleepData: Codable {
    let duration: String
}

struct CoachResponse: Codable {
    let answer: String
}

struct ChatMessagePayload: Codable {
    let role: String
    let content: String
}

struct JournalEntryPayload: Codable {
    let mood: String
    let content: String?
    let date: String
}

struct JournalEntryResponse: Codable {
    let id: Int
    let userId: Int
    let date: String
    let mood: String
    let content: String?
}

struct ActivityRequest: Codable {
    let activity_type: String
    let duration: TimeInterval
    let distance: Double?
    let date: Date
    let owner_id: Int
}


// MARK: - Network Service
class NetworkService {
    
    static let shared = NetworkService()
    private let baseURL = URL(string: "https://harmonia-api-378861620628.us-central1.run.app/")!

    private init() {}
    
    enum NetworkError: Error {
        case encodingFailed(Error)
        case badImageData
    }
    
    private func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Decodificador para lidar com as datas
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = formatter.date(from: dateString) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        })
        
        return decoder
    }

    private func createEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    private struct LoginRequest: Codable {
        let name: String
        let email: String
    }
    
    // MARK: - Funções de usuário e autenticação
    
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
    
    // MARK: Atividades
    
    func fetchActivities(for userId: Int, completion: @escaping (Result<[Activity], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/users/\(userId)/activities/")
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                do {
                    let activities = try self.createDecoder().decode([Activity].self, from: data)
                    completion(.success(activities))
                } catch {
                    print("Erro ao decodificar atividades: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func saveActivity(_ activity: Activity, for userId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/activities/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ActivityRequest(
            activity_type: activity.activityType.rawValue,
            duration: activity.duration,
            distance: activity.distance,
            date: activity.date,
            owner_id: userId
        )

        do {
            let encoder = createEncoder()
            let data = try encoder.encode(payload)
            request.httpBody = data
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON para API:")
                print(jsonString)
            }

        } catch {
            print("Erro ao codificar o JSON: \(error)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    if let data = data, let errorString = String(data: data, encoding: .utf8) {
                        print("Erro recebido do backend \(httpResponse.statusCode)):")
                        print(errorString)
                    }
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                
                completion(.success(()))
            }
        }.resume()
    }
    
    // MARK: - Funções de hábitos
    
    func toggleHabitCompletion(habitId: Int, dateString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("/habits/\(habitId)/toggle"), resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "date_str", value: dateString)
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                completion(.success(()))
            }
        }.resume()
    }

    func fetchHabitHistory(habitId: Int, completion: @escaping (Result<HabitHistoryResponse, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/habits/\(habitId)/history")
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.failure(URLError(.badServerResponse))); return }
                do {
                    let historyResponse = try self.createDecoder().decode(HabitHistoryResponse.self, from: data)
                    completion(.success(historyResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func addHabit(userId: Int, name: String, icon: String, completion: @escaping (Result<HabitStatus, Error>) -> Void) {
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
                    let newHabit = try self.createDecoder().decode(HabitStatus.self, from: data)
                    completion(.success(newHabit))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Funções de IA e dashboard
    
    func fetchDashboardData(userId: Int, date: Date, completion: @escaping (Result<DashboardDataResponse, Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("/dashboard/user/\(userId)"), resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [URLQueryItem(name: "date_str", value: dateString)]
        
        URLSession.shared.dataTask(with: urlComponents.url!) { data, _, error in
            DispatchQueue.main.async {
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.failure(URLError(.badServerResponse))); return }
                do {
                    let dashboardResponse = try self.createDecoder().decode(DashboardDataResponse.self, from: data)
                    completion(.success(dashboardResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
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
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
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
    
    // MARK: - Funções de diário
    
    func saveJournalEntry(userId: Int, mood: String, content: String?, date: Date, completion: @escaping (Result<JournalEntryResponse, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/users/\(userId)/journal")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let payload = JournalEntryPayload(mood: mood, content: content, date: dateString)
        
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                do {
                    let decoder = self.createDecoder()
                    let journalEntry = try decoder.decode(JournalEntryResponse.self, from: data)
                    completion(.success(journalEntry))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func fetchJournalEntries(userId: Int, completion: @escaping (Result<[JournalEntry], Error>) -> Void) {
        let url = self.baseURL.appendingPathComponent("/journal_entries/\(userId)")
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                
                do {
                    let decoder = self.createDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    let entries = try decoder.decode([JournalEntry].self, from: data)
                    completion(.success(entries))
                } catch {
                    print("DEBUG: Erro ao decodificar Journal Entries: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    func analyzeMeal(image: UIImage, completion: @escaping (Result<NutritionAnalysisResponse, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("nutrition/analyze-meal")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NetworkError.badImageData))
            return
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"meal.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                
                do {
                    let decodedResponse = try self.createDecoder().decode(NutritionAnalysisResponse.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print("Decoding Error in analyzeMeal: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func saveNutritionLog(log: NutritionLogCreate, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("nutrition")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try createEncoder().encode(log)
        } catch {
            completion(.failure(NetworkError.encodingFailed(error)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    completion(.success(()))
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
            }
        }.resume()
    }
}
