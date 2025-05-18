import Foundation

protocol TaskDetailsPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didChangeText(title: String, description: String)
    func didTapSave(newTitle: String, newDescription: String)
}

final class TaskDetailsPresenter {
    weak var view: TaskDetailsViewProtocol?
    private let interactor: TaskDetailsInteractorProtocol
    private let router: TaskDetailsRouterProtocol
    private var originalTask: Task

    init(view: TaskDetailsViewProtocol,
         interactor: TaskDetailsInteractorProtocol,
         router: TaskDetailsRouterProtocol,
         task: Task)
    {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.originalTask = task
    }

    private func hasChanges(title: String, description: String) -> Bool {
        let origDescription = originalTask.description ?? ""
        return title != originalTask.todo || description != origDescription
    }
}

extension TaskDetailsPresenter: TaskDetailsPresenterProtocol {
    func viewDidLoad() {
        view?.showTask(originalTask)
    }

    func didChangeText(title: String, description: String) {
        let changed = hasChanges(title: title, description: description)
        view?.setSaveEnabled(changed)
    }

    func didTapSave(newTitle: String, newDescription: String) {
        let updatedTask = Task(
            id: originalTask.id,
            todo: newTitle,
            completed: originalTask.completed,
            userId: originalTask.userId,
            date: originalTask.date,
            description: newDescription
        )
        interactor.updateTask(updatedTask)
    }
}

extension TaskDetailsPresenter: TaskDetailsInteractorOutput {
    func didUpdateTask(_ task: Task) {
        if let viewController = view as? TaskDetailsViewController {
            viewController.delegate?.didUpdateTask(task)
        }
        router.closeDetails()
    }
}
