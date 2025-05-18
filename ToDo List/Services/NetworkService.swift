import Foundation

protocol NetworkServiceProtocol {
    func fetchTasks(completion: @escaping (Result<[Task], Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    private let apiURL = URL(string: "https://drive.google.com/uc?id=1MXypRbK2CS9fqPhTtPonn580h1sHUs2W&export=download")!
    
    func fetchTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        let request = URLRequest(url: apiURL)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let httpError = NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Некорректный HTTP-ответ"])
                completion(.failure(httpError))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет данных"])))
                return
            }
            
            print("Raw data as String: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            do {
                let decoder = JSONDecoder()
                let tasks = try decoder.decode([Task].self, from: try self.extractTodosArray(from: data))
                completion(.success(tasks))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func extractTodosArray(from jsonData: Data) throws -> Data {
        if let stringData = String(data: jsonData, encoding: .utf8) {
            print("Raw JSON data: \(stringData)")
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        guard let todosArray = jsonObject?["todos"] else {
            throw NSError(domain: "Invalid JSON structure", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не найден ключ 'todos'"])
        }
        
        let todosData = try JSONSerialization.data(withJSONObject: todosArray, options: [])
        return todosData
    }
}
