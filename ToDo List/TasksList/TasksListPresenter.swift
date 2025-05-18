import UIKit

protocol TasksListPresenterProtocol {
    var tasksCount: Int { get }
    func task(at index: Int) -> Task
    func viewDidLoad()
    func didSelectTask(at index: Int)
    func didSelectTask(task: Task)
    func toggleTaskCompletion(for: Task)
    func searchTasks(with searchText: String)
    func indexForTask(_ task: Task) -> Int?
    func updateTask(_ task: Task)
    func addTask(_ task: Task)
    func deleteTask(_ task: Task)
}

class TasksListPresenter: TasksListPresenterProtocol {
    
    weak var view: TasksListViewControllerProtocol?
    private let router: TasksListRouterProtocol
    private let interactor: TasksListInteractorProtocol
    private var allTasks: [Task] = []
    private var filteredTasks: [Task] = []
    
    init(router: TasksListRouterProtocol, interactor: TasksListInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        view?.showLoadingIndicator()
        interactor.fetchTasks(search: nil) { [weak self] tasks in
            guard let self = self else { return }
            self.allTasks = tasks
            self.filteredTasks = tasks
            self.view?.hideLoadingIndicator()
            self.view?.reloadData()
        }
    }
    
    var tasksCount: Int {
        filteredTasks.count
    }
    
    func task(at index: Int) -> Task {
        filteredTasks[index]
    }
    
    func didSelectTask(at index: Int) {
        let selectedTask = filteredTasks[index]
        router.navigateToTaskDetails(with: selectedTask, delegate: view as? TaskDetailsViewControllerDelegate)
    }
    
    func didSelectTask(task: Task) {
        router.navigateToTaskDetails(with: task, delegate: view as? TaskDetailsViewControllerDelegate)
    }
    
    func searchTasks(with searchText: String) {
        interactor.fetchTasks(search: searchText) { [weak self] tasks in
            self?.filteredTasks = tasks
            self?.view?.reloadData()
        }
    }
    
    func toggleTaskCompletion(for task: Task) {
        guard let index = allTasks.firstIndex(where: { $0.id == task.id }) else { return }
        allTasks[index].completed.toggle()
        if let filteredIndex = filteredTasks.firstIndex(where: { $0.id == task.id }) {
            filteredTasks[filteredIndex] = allTasks[index]
        }
    }
    
    func indexForTask(_ task: Task) -> Int? {
        return filteredTasks.firstIndex(where: { $0.id == task.id })
    }
    
    func updateTask(_ task: Task) {
        interactor.updateTask(task) { [weak self] tasks in
            self?.allTasks = tasks
            self?.filteredTasks = tasks
            self?.view?.reloadData()
        }
    }
    
    func addTask(_ task: Task) {
        interactor.addTask(task) { [weak self] tasks in
            guard let self = self else { return }
            self.allTasks = tasks
            self.filteredTasks = tasks
            DispatchQueue.main.async {
                self.view?.reloadData()
                self.router.navigateToTaskDetails(with: task, delegate: self.view as? TaskDetailsViewControllerDelegate)
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        interactor.deleteTask(task) { [weak self] tasks in
            self?.allTasks = tasks
            self?.filteredTasks = tasks
            self?.view?.reloadData()
        }
    }
}
