import UIKit

protocol TasksListPresenterProtocol {
    var tasksCount: Int { get }
    func task(at index: Int) -> Task
    func viewDidLoad()
    func didSelectTask(at index: Int)
    func toggleTaskCompletion(for: Task)
    func startVoiceSearch()
    func stopVoiceSearch()
    func searchTasks(with searchText: String)
    func indexForTask(_ task: Task) -> Int?
    func toggleVoiceRecognition()
    func updateTask(_ task: Task)
}

class TasksListPresenter: TasksListPresenterProtocol {
    func updateTask(_ task: Task) {
        if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
                allTasks[index] = task
            }
            if let fIndex = filteredTasks.firstIndex(where: { $0.id == task.id }) {
                filteredTasks[fIndex] = task
            }
            view?.reloadData()
    }
    
    weak var view: TasksListViewControllerProtocol?
    private let router: TasksListRouterProtocol
    private let interactor: TasksListInteractorProtocol
    private var allTasks: [Task] = []
    private var filteredTasks: [Task] = []
    private var isListening = false
    

    init(router: TasksListRouterProtocol, interactor: TasksListInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        view?.showLoadingIndicator()
        interactor.fetchTasks { [weak self] tasks in
            DispatchQueue.main.async {
                self?.view?.hideLoadingIndicator()
                if tasks.isEmpty {
                    self?.view?.displayError("Список задач пуст.")
                } else {
                    self?.allTasks = tasks
                    self?.filteredTasks = tasks
                    self?.view?.reloadData()
                }
            }
        }
    }
    
    func toggleVoiceRecognition() {
        if isListening {
            stopVoiceSearch()
        } else {
            startVoiceSearch()
        }
    }
    
    func startVoiceSearch() {
        guard !isListening else {
            return stopVoiceSearch()
        }

        isListening = true
        view?.setMicButtonState(isListening: true)
        
        interactor.startSpeechRecognition { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let text):
                print("Распознанный текст: \(text)")
                self.view?.updateSearchBar(with: text)
                self.searchTasks(with: text)

            case .failure(let error):
                if let speechError = error as NSError?,
                   speechError.domain == "kAFAssistantErrorDomain",
                   speechError.code == 1101 {
                    print("Ошибка 'No speech detected' — перезапуск")
                    self.startVoiceSearch()
                } else {
                    self.view?.showError(message: error.localizedDescription)
                }
            }
            self.stopVoiceSearch()
        }
    }
    
    func stopVoiceSearch() {
        guard isListening else { return }
        
        isListening = false
        view?.setMicButtonState(isListening: false)
        interactor.stopSpeechRecognition()
    }

    var tasksCount: Int {
        filteredTasks.count
    }

    func task(at index: Int) -> Task {
        filteredTasks[index]
    }

    func didSelectTask(at index: Int) {
        let selectedTask = allTasks[index]
        router.navigateToTaskDetails(with: selectedTask)
    }
    
    func searchTasks(with searchText: String) {
        if searchText.isEmpty {
            filteredTasks = allTasks
        } else {
            filteredTasks = allTasks.filter { task in
                task.todo.lowercased().contains(searchText.lowercased())
            }
        }
        view?.reloadData()
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
}

