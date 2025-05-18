//
//  MockRouter.swift
//  ToDo ListTests
//
//  Created by Fedor Bebinov on 26.03.2025.
//

import XCTest
@testable import ToDo_List

class MockRouter: TasksListRouterProtocol {
    var isNavigateToTaskDetailsCalled = false
    var passedTask: Task?

    func navigateToTaskDetails(with task: Task) {
        isNavigateToTaskDetailsCalled = true
        passedTask = task
    }
}
