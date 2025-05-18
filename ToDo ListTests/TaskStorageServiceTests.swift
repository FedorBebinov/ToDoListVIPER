import XCTest
@testable import ToDo_List

class TaskStorageServiceTests: XCTestCase {

    var storage: TaskStorageService!
    
    override func setUp() {
        super.setUp()
        storage = TaskStorageService.shared
        let all = storage.fetchTasks()
        for t in all {
            storage.deleteTask(id: t.id)
        }
    }

    func testAddFetchUpdateDelete() {
        let task = Task(id: 1234, todo: "storage", completed: false, userId: 1, date: Date(), description: "desc")
        storage.addTask(task)
        // fetch
        let fetched = storage.fetchTasks()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first!.todo, "storage")
        // update
        let task2 = Task(id: 1234, todo: "changed", completed: true, userId: 1, date: Date(), description: "desc2")
        storage.updateTask(task2)
        let updated = storage.fetchTasks().first!
        XCTAssertTrue(updated.completed)
        XCTAssertEqual(updated.todo, "changed")
        // delete
        storage.deleteTask(id: 1234)
        XCTAssertEqual(storage.fetchTasks().count, 0)
    }
}
