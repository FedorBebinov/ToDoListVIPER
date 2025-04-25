import UIKit

protocol TasksListInteractorProtocol {
    func fetchTasks(completion: @escaping ([Task]) -> Void)
    func startSpeechRecognition(completion: @escaping (Result<String, Error>) -> Void)
    func stopSpeechRecognition()
}

class TasksListInteractor: TasksListInteractorProtocol {
    
    private let speechService: SpeechRecognitionServiceProtocol
    private let networkService: NetworkServiceProtocol
    
    init(speechService: SpeechRecognitionServiceProtocol, networkService: NetworkServiceProtocol) {
        self.speechService = speechService
        self.networkService = networkService
    }
    
    func startSpeechRecognition(completion: @escaping (Result<String, Error>) -> Void) {
        speechService.startRecognition(completion: completion)
    }
    
    func stopSpeechRecognition() {
        speechService.stopRecognition()
    }
    
    func fetchTasks(completion: @escaping ([Task]) -> Void) {
        networkService.fetchTasks { result in
            switch result {
            case .success(let tasks):
                let updatedTasks = self.generateAdditionalData(for: tasks)
                DispatchQueue.main.async {
                    completion(updatedTasks)
                }
            case .failure(let error):
                print("Ошибка загрузки задач: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([]) // Возвращаем пустой массив при ошибке.
                }
            }
        }
    }
    
    private func generateAdditionalData(for tasks: [Task]) -> [Task] {
        return tasks.map { task in
            let description = "Описание задачи: \(task.todo.lowercased())"
            let creationDate = Date()
            
            return Task(
                id: task.id,
                todo: task.todo,
                completed: task.completed,
                userId: task.userId,
                date: creationDate,
                description: description 
            )
        }
    }
}
