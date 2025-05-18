import XCTest
@testable import ToDo_List

class NetworkServiceTests: XCTestCase {

    func testExtractTodosArrayParses() throws {
        let sut = NetworkService()
        let data = #"{"todos":[{"id":1,"todo":"abc","completed":false,"userId":1,"date":null,"description":"desc"}]}"#.data(using: .utf8)!
        let todosData = try sut.extractTodosArray(from: data)
        let tasks = try JSONDecoder().decode([Task].self, from: todosData)
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks[0].todo, "abc")
    }
}
