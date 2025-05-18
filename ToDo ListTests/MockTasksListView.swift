//
//  MockTasksListView.swift
//  ToDo ListTests
//
//  Created by Fedor Bebinov on 26.03.2025.
//
import XCTest
@testable import ToDo_List


class MockTasksListView: TasksListViewControllerProtocol {
    var isReloadDataCalled = false
    var isUpdateSearchBarCalled = false
    var errorMessage: String?

    func reloadData() {
        isReloadDataCalled = true
    }

    func updateSearchBar(with text: String) {
        isUpdateSearchBarCalled = true
    }

    func showError(message: String) {
        errorMessage = message
    }
}

