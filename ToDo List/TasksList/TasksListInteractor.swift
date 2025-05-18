import Foundation

protocol TasksListInteractorProtocol {
    func fetchTasks(search: String?, completion: @escaping ([Task]) -> Void)
    func addTask(_ task: Task, completion: @escaping ([Task]) -> Void)
    func updateTask(_ task: Task, completion: @escaping ([Task]) -> Void)
    func deleteTask(_ task: Task, completion: @escaping ([Task]) -> Void)
}

class TasksListInteractor: TasksListInteractorProtocol {
    private let networkService: NetworkServiceProtocol
    private let storageService = TaskStorageService.shared
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchTasks(search: String? = nil, completion: @escaping ([Task]) -> Void) {
        if !UserDefaults.standard.bool(forKey: AppConstants.hasLoadedTasks) {
            networkService.fetchTasks { [weak self] result in
                switch result {
                case .success(let tasks):
                    let preparedTasks = tasks.map { task in
                        Task(
                            id: task.id,
                            todo: task.todo,
                            completed: task.completed,
                            userId: task.userId,
                            date: task.date,
                            description: ((task.description ?? "").isEmpty ? "Описание для \"\(task.todo)\"" : task.description)
                        )
                    }
                    for task in preparedTasks {
                        self?.storageService.addTask(task)
                    }
                    UserDefaults.standard.set(true, forKey: AppConstants.hasLoadedTasks)
                    let fetched = self?.storageService.fetchTasks(search: search) ?? []
                    DispatchQueue.main.async { completion(fetched) }
                case .failure(_):
                    let fetched = self?.storageService.fetchTasks(search: search) ?? []
                    DispatchQueue.main.async { completion(fetched) }
                }
            }
        } else {
            let tasks = storageService.fetchTasks(search: search)
            completion(tasks)
        }
    }
    
    func addTask(_ task: Task, completion: @escaping ([Task]) -> Void) {
        storageService.addTask(task)
        let tasks = storageService.fetchTasks()
        completion(tasks)
    }
    
    func updateTask(_ task: Task, completion: @escaping ([Task]) -> Void) {
        storageService.updateTask(task)
        let tasks = storageService.fetchTasks()
        completion(tasks)
    }
    
    func deleteTask(_ task: Task, completion: @escaping ([Task]) -> Void) {
        storageService.deleteTask(id: task.id)
        let tasks = storageService.fetchTasks()
        completion(tasks)
    }
}
