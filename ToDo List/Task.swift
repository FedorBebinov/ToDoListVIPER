import Foundation

struct Task: Decodable {
    let id: Int
    let todo: String
    var completed: Bool
    let userId: Int
    let date: Date?
    let description: String?
}
