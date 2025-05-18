import XCTest

@testable import ToDo_List

final class TaskDetailsInteractorTests: XCTestCase {
    
    // MARK: - Моки
    
    final class MockOutput: TaskDetailsInteractorOutput {
        var didUpdateTaskResult: Task?
        func didUpdateTask(_ task: Task) {
            didUpdateTaskResult = task
        }
    }
    
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    
    func testUpdateTask_callsStorage_andSendsResultToOutput() {
        // Arrange
        let origTask = Task(id: 300, todo: "single", completed: false, userId: 9, date: Date(), description: "x")
        let interactor = TaskDetailsInteractor(task: origTask)
        let mockOutput = MockOutput()
        interactor.output = mockOutput
        
        let newTask = Task(id: 300, todo: "changed!", completed: true, userId: 9, date: origTask.date, description: "y")
        
        // Act
        interactor.updateTask(newTask)
        
        // Assert
        XCTAssertNotNil(mockOutput.didUpdateTaskResult)
        XCTAssertEqual(mockOutput.didUpdateTaskResult?.id, newTask.id)
        XCTAssertEqual(mockOutput.didUpdateTaskResult?.todo, newTask.todo)
        XCTAssertEqual(mockOutput.didUpdateTaskResult?.completed, newTask.completed)
        XCTAssertEqual(mockOutput.didUpdateTaskResult?.userId, newTask.userId)
        XCTAssertEqual(mockOutput.didUpdateTaskResult?.description, newTask.description)
    }
}
