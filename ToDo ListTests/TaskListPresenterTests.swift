import XCTest
@testable import ToDo_List

class TasksListPresenterTests: XCTestCase {
    
    class MockView: TasksListViewControllerProtocol {
        var reloadDataCalled = false
        var errorShown = false
        var lastErrorMessage: String?
        func reloadData() { reloadDataCalled = true }
        func updateSearchBar(with text: String) {}
        func showError(message: String) { errorShown = true; lastErrorMessage = message }
        func setMicButtonState(isListening: Bool) {}
        func showLoadingIndicator() {}
        func hideLoadingIndicator() {}
        func displayError(_ message: String) { errorShown = true; lastErrorMessage = message }
    }
    
    class MockInteractor: TasksListInteractorProtocol {
        var tasks: [Task] = []
        var addTaskCalled = false
        var updateTaskCalled = false
        var deleteTaskCalled = false
        var fetchTasksCalled = false
        
        func fetchTasks(search: String?, completion: @escaping ([Task]) -> Void) {
            fetchTasksCalled = true
            completion(tasks)
        }
        func addTask(_ task: Task, completion: @escaping ([Task]) -> Void) {
            addTaskCalled = true
            tasks.append(task)
            completion(tasks)
        }
        func updateTask(_ task: Task, completion: @escaping ([Task]) -> Void) {
            updateTaskCalled = true
            tasks = tasks.map { $0.id == task.id ? task : $0 }
            completion(tasks)
        }
        func deleteTask(_ task: Task, completion: @escaping ([Task]) -> Void) {
            deleteTaskCalled = true
            tasks = tasks.filter { $0.id != task.id }
            completion(tasks)
        }
    }
    
    class MockRouter: TasksListRouterProtocol {
        var navigateToDetailsCalled = false
        var lastTask: Task?
        func navigateToTaskDetails(with task: Task, delegate: TaskDetailsViewControllerDelegate?) {
            navigateToDetailsCalled = true
            lastTask = task
        }
    }
    
    func sampleTask(id: Int = 1, completed: Bool = false) -> Task {
        return Task(id: id, todo: "Sample", completed: completed, userId: 1, date: Date(), description: "desc")
    }
    
    func testViewDidLoadFetchesTasksAndReloads() {
        let view = MockView()
        let interactor = MockInteractor()
        interactor.tasks = [sampleTask()]
        let presenter = TasksListPresenter(router: MockRouter(), interactor: interactor)
        presenter.view = view
        presenter.viewDidLoad()
        XCTAssertTrue(interactor.fetchTasksCalled)
        XCTAssertTrue(view.reloadDataCalled)
        XCTAssertEqual(presenter.tasksCount, 1)
        XCTAssertEqual(presenter.task(at: 0).todo, "Sample")
    }
    
    func testDidSelectTaskAtNavigates() {
        let presenter = TasksListPresenter(router: MockRouter(), interactor: MockInteractor())
        let interactor = MockInteractor()
        interactor.tasks = [sampleTask()]
        let view = MockView()
        presenter.view = view
        presenter.updateTask(sampleTask())
        let router = MockRouter()
        let view2 = MockView()
        presenter.view = view2
        let presenter2 = TasksListPresenter(router: router, interactor: interactor)
        let view3 = MockView()
        presenter.view = view3
        presenter2.updateTask(sampleTask())
        presenter2.didSelectTask(at: 0)
        XCTAssertTrue(router.navigateToDetailsCalled)
        XCTAssertEqual(router.lastTask?.todo, "Sample")
    }
    
    func testDeleteTaskRemovesTask() {
        let view = MockView()
        let interactor = MockInteractor()
        let router = MockRouter()
        let task = sampleTask(id: 2)
        interactor.tasks = [task]
        let presenter = TasksListPresenter(router: router, interactor: interactor)
        presenter.view = view
        presenter.updateTask(task)
        presenter.deleteTask(task)
        XCTAssertTrue(interactor.deleteTaskCalled)
        XCTAssertTrue(view.reloadDataCalled)
        XCTAssertEqual(presenter.tasksCount, 0)
    }
    
    func testToggleTaskCompletionChangesCompletion() {
        let interactor = MockInteractor()
        interactor.tasks = [sampleTask(id: 33, completed: false)]
        let presenter = TasksListPresenter(router: MockRouter(), interactor: interactor)
        let view = MockView()
        presenter.view = view
        presenter.updateTask(sampleTask(id: 33, completed: false))
        let before = presenter.task(at: 0).completed
        presenter.toggleTaskCompletion(for: sampleTask(id: 33, completed: false))
        let after = presenter.task(at: 0).completed
        XCTAssertNotEqual(before, after)
    }
    
    func testSearchTasksFilters() {
        let view = MockView()
        let interactor = MockInteractor()
        let task1 = Task(id: 1, todo: "Test", completed: false, userId: 1, date: Date(), description: "d1")
        let task2 = Task(id: 2, todo: "Other", completed: false, userId: 1, date: Date(), description: "d2")
        interactor.tasks = [task1, task2]
        let presenter = TasksListPresenter(router: MockRouter(), interactor: interactor)
        presenter.view = view
        presenter.updateTask(task1)
        presenter.updateTask(task2)
        interactor.tasks = [task1] 
        presenter.searchTasks(with: "Test")
        XCTAssertEqual(presenter.tasksCount, 1)
        XCTAssertTrue(view.reloadDataCalled)
    }
    
    func testIndexForTask() {
        let presenter = TasksListPresenter(router: MockRouter(), interactor: MockInteractor())
        let view = MockView()
        presenter.view = view
        
        let task = sampleTask(id: 999)
        presenter.addTask(task)
        XCTAssertNotNil(presenter.indexForTask(task), "Index for known task должен быть ненулевым")
    }
}
