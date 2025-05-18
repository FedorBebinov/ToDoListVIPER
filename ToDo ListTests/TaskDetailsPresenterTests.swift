import XCTest

@testable import ToDo_List 

final class TaskDetailsPresenterTests: XCTestCase {
    
    // MARK: - Mocks
    
    final class MockView: TaskDetailsViewProtocol {
        var shownTask: Task?
        var saveEnabled: Bool?
        
        func showTask(_ task: Task) {
            shownTask = task
        }
        
        func setSaveEnabled(_ enabled: Bool) {
            saveEnabled = enabled
        }
    }
    
    final class MockInteractor: TaskDetailsInteractorProtocol {
        var updatedTask: Task?
        var deleteCalled = false
        
        func updateTask(_ task: Task) {
            updatedTask = task
        }
        
        func deleteTask() {
            deleteCalled = true
        }
    }
    
    final class MockRouter: TaskDetailsRouterProtocol {
        var closeDetailsCalled = false
        func closeDetails() { closeDetailsCalled = true }
        func open(with task: Task, delegate: TaskDetailsViewControllerDelegate?) {}
    }
    
    final class MockDelegate: TaskDetailsViewControllerDelegate {
        var updatedTask: Task?
        func didUpdateTask(_ task: Task) {
            updatedTask = task
        }
    }
    
    // MARK: - Sample Data
    
    var sampleTask: Task {
        .init(
            id: 1,
            todo: "Test",
            completed: false,
            userId: 77,
            date: Date(timeIntervalSince1970: 1_712_000_000),
            description: "Desc"
        )
    }
    
    // MARK: - Tests
    
    func testViewDidLoad_ShowsTask() {
        let mockView = MockView()
        let presenter = makePresenter(mockView: mockView)
        presenter.viewDidLoad()
        XCTAssertEqual(mockView.shownTask?.id, sampleTask.id)
        XCTAssertEqual(mockView.shownTask?.todo, sampleTask.todo)
        XCTAssertEqual(mockView.shownTask?.description, sampleTask.description)
    }
    
    func testDidChangeText_NoChange_DisablesSave() {
        let mockView = MockView()
        let presenter = makePresenter(mockView: mockView)
        let orig = sampleTask
        presenter.didChangeText(title: orig.todo, description: orig.description ?? "")
        XCTAssertEqual(mockView.saveEnabled, false)
    }
    
    func testDidChangeText_TitleChanged_EnablesSave() {
        let mockView = MockView()
        let presenter = makePresenter(mockView: mockView)
        presenter.didChangeText(title: "New Title", description: sampleTask.description ?? "")
        XCTAssertEqual(mockView.saveEnabled, true)
    }
    
    func testDidChangeText_DescChanged_EnablesSave() {
        let mockView = MockView()
        let presenter = makePresenter(mockView: mockView)
        presenter.didChangeText(title: sampleTask.todo, description: "newdesc")
        XCTAssertEqual(mockView.saveEnabled, true)
    }
    
    func testDidTapSave_CallsInteractorUpdateTask() {
        let mockInteractor = MockInteractor()
        let presenter = makePresenter(mockInteractor: mockInteractor)
        let newTitle = "Buy lemon"
        let newDesc = "From the market"
        presenter.didTapSave(newTitle: newTitle, newDescription: newDesc)
        XCTAssertEqual(mockInteractor.updatedTask?.todo, newTitle)
        XCTAssertEqual(mockInteractor.updatedTask?.description, newDesc)
        XCTAssertEqual(mockInteractor.updatedTask?.id, sampleTask.id)
    }
    
    func testDidUpdateTask_NotifiesDelegateAndClosesRouter() {
        let mockRouter = MockRouter()
        let mockDelegate = MockDelegate()
        let presenter = makePresenter(mockRouter: mockRouter)
        let vc = TaskDetailsViewController()
        vc.presenter = presenter
        vc.delegate = mockDelegate
        presenter.view = vc
        
        let updatedTask = Task(id: 5, todo: "New", completed: false, userId: 1, date: Date(), description: "Some")
        presenter.didUpdateTask(updatedTask)
        XCTAssertEqual(mockDelegate.updatedTask?.id, updatedTask.id)
        XCTAssertTrue(mockRouter.closeDetailsCalled)
    }
    
    // MARK: - Helpers
    
    private func makePresenter(
        mockView: TaskDetailsViewProtocol? = nil,
        mockInteractor: TaskDetailsInteractorProtocol? = nil,
        mockRouter: TaskDetailsRouterProtocol? = nil
    ) -> TaskDetailsPresenter {
        let view = mockView ?? MockView()
        let interactor = mockInteractor ?? MockInteractor()
        let router = mockRouter ?? MockRouter()
        return TaskDetailsPresenter(
            view: view,
            interactor: interactor,
            router: router,
            task: sampleTask
        )
    }
}
