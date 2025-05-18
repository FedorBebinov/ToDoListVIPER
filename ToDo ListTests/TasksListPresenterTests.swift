
/*import XCTest
@testable import ToDo_List

class TasksListPresenterTests: XCTestCase {

    var presenter: TasksListPresenter!
    var viewMock: MockTasksListView!
    var interactorMock: MockInteractor!
    var routerMock: MockRouter!

    override func setUp() {
        super.setUp()
        viewMock = MockTasksListView()
        interactorMock = MockInteractor()
        routerMock = MockRouter()
        presenter = TasksListPresenter(router: routerMock, interactor: interactorMock)
        presenter.view = viewMock
    }

    func testViewDidLoadFetchesTasks() {
        // Act
        presenter.viewDidLoad()

        // Assert
        XCTAssertTrue(interactorMock.isFetchTasksCalled, "Interactor should fetch tasks on viewDidLoad")
        XCTAssertTrue(viewMock.isReloadDataCalled, "View should reload data after fetching tasks")
    }

    func testSearchTasksFiltersCorrectly() {
        // Arrange
        interactorMock.tasks = [
            Task(id: 1, todo: "Купить продукты", completed: false, userId: 1, date: Date(), description: ""),
            Task(id: 2, todo: "Сходить в спортзал", completed: true, userId: 1, date: Date(), description: "")
        ]
        presenter.viewDidLoad() // Initialize tasks
        let searchText = "спортзал"

        // Act
        presenter.searchTasks(with: searchText)

        // Assert
        XCTAssertEqual(presenter.tasksCount, 1, "Search should filter tasks correctly")
        XCTAssertTrue(viewMock.isReloadDataCalled, "View should reload data after search")
    }

    func testToggleTaskCompletionUpdatesTasks() {
        // Arrange
        interactorMock.tasks = [
            Task(id: 1, todo: "Купить продукты", completed: false, userId: 1, date: Date(), description: "")
        ]
        presenter.viewDidLoad()
        let task = presenter.task(at: 0)

        // Act
        presenter.toggleTaskCompletion(for: task)

        // Assert
        XCTAssertTrue(interactorMock.tasks[0].completed, "Task completion should toggle")
        XCTAssertTrue(viewMock.isReloadDataCalled, "View should reload data after toggling task completion")
    }
}*/
