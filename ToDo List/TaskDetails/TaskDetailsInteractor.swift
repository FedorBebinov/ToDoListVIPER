import Foundation

protocol TaskDetailsInteractorProtocol: AnyObject {
    func updateTask(_ task: Task)
    func deleteTask()
}

protocol TaskDetailsInteractorOutput: AnyObject {
    func didUpdateTask(_ task: Task)
}

final class TaskDetailsInteractor: TaskDetailsInteractorProtocol {
    weak var output: TaskDetailsInteractorOutput?
    private var currentTask: Task
    private let storageService = TaskStorageService.shared
    
    init(task: Task) {
        self.currentTask = task
    }
    
    func updateTask(_ task: Task) {
        storageService.updateTask(task)
        currentTask = task
        output?.didUpdateTask(task)
    }
    
    func deleteTask() {
        storageService.deleteTask(id: currentTask.id)
    }
}
