import XCTest
@testable import ToDo_List

class TasksListInteractorTests: XCTestCase {

    class MockNetwork: NetworkServiceProtocol {
        var fetched = false
        func fetchTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
            fetched = true
            let task = Task(id: 11, todo: "NetworkTask", completed: false, userId: 1, date: Date(), description: "desc")
            completion(.success([task]))
        }
    }

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: AppConstants.hasLoadedTasks)
        let storage = TaskStorageService.shared
        let all = storage.fetchTasks()
        for t in all {
            storage.deleteTask(id: t.id)
        }
    }
    
    func testFirstFetchLoadsFromNetworkAndCaches() {
        let network = MockNetwork()
        let interactor = TasksListInteractor(networkService: network)
        let exp = expectation(description: "network")
        interactor.fetchTasks(search: nil) { tasks in
            XCTAssertTrue(network.fetched)
            XCTAssertTrue(tasks.contains(where: { $0.todo == "NetworkTask" }))
            XCTAssertTrue(UserDefaults.standard.bool(forKey: AppConstants.hasLoadedTasks), "Tasks are cached")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testAddTaskAppends() {
        let interactor = TasksListInteractor(networkService: MockNetwork())
        let exp = expectation(description: "add")
        let newTask = Task(id: 2, todo: "New", completed: false, userId: 1, date: Date(), description: nil)
        interactor.addTask(newTask) { tasks in
            XCTAssertTrue(tasks.contains(where: { $0.todo == "New" }))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testUpdateTaskWorks() {
        let interactor = TasksListInteractor(networkService: MockNetwork())
        let task = Task(id: 8, todo: "old", completed: false, userId: 1, date: Date(), description: "desc")
        interactor.addTask(task) { _ in }
        let exp = expectation(description: "update")
        let updated = Task(id: 8, todo: "updated", completed: true, userId: 1, date: Date(), description: "desc")
        interactor.updateTask(updated) { tasks in
            let t = tasks.first(where: { $0.id == 8 })
            XCTAssertNotNil(t)
            XCTAssertEqual(t!.todo, "updated")
            XCTAssertTrue(t!.completed)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testDeleteTaskWorks() {
        let interactor = TasksListInteractor(networkService: MockNetwork())
        let addExp = expectation(description: "add")
        let task = Task(id: 100, todo: "del", completed: false, userId: 1, date: Date(), description: nil)
        interactor.addTask(task) { _ in addExp.fulfill() }
        wait(for: [addExp], timeout: 1)
        let delExp = expectation(description: "delete")
        interactor.deleteTask(task) { tasks in
            XCTAssertFalse(tasks.contains(where: { $0.id == 100 }))
            delExp.fulfill()
        }
        wait(for: [delExp], timeout: 1)
    }
}
