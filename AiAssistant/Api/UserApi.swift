import Foundation

final class UserApi {
    static let shared = UserApi()
    
    private init() {}
    
    func registerUser() async throws {
        guard let userId = Constants.shared.userId else { throw ApiError.encodingFailded }
        
        guard let url = URL(string: "\(Constants.shared.apiBaseUrl)/api/user/register?userId=\(userId)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw ApiError.invalidResponse
        }
        
        if let stringData = String(data: data, encoding: .utf8) {
            print("Register user response: \(stringData)")
        }
    }
    
    func getApiKey() async throws {
        guard let url = URL(string: "\(Constants.shared.apiBaseUrl)/api/user/get-api-key") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let stringData = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                Constants.shared.apiKey = stringData
            }
        }
    }
    
    func redeemProCode(_ code: String) async throws {
        guard let userId = Constants.shared.userId else { throw ApiError.encodingFailded }
        
        guard let url = URL(string: "\(Constants.shared.apiBaseUrl)/api/code/activate-code?userId=\(userId)&activationCode=\(code)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw ApiError.invalidResponse
        }
        
        DispatchQueue.main.async {
            AppState.shared.isProUser = true
        }
    }
    
    func fetchUserStatus() async throws {
        guard let userId = Constants.shared.userId else { throw ApiError.encodingFailded }
        
        guard let url = URL(string: "\(Constants.shared.apiBaseUrl)/api/user/fetch-user?userId=\(userId)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw ApiError.invalidResponse
        }
        
        if let stringData = String(data: data, encoding: .utf8) {
            print("User Status: \(stringData)")
        }
        
        let decoded = try JSONDecoder().decode(User.self, from: data)
        
        DispatchQueue.main.async {
            AppState.shared.isProUser = decoded.isPro
        }
    }
}
