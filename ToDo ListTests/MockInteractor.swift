//
//  MockInteractor.swift
//  ToDo ListTests
//
//  Created by Fedor Bebinov on 26.03.2025.
//
import XCTest
@testable import ToDo_List

class MockInteractor: TasksListInteractorProtocol {
    var isFetchTasksCalled = false
    var tasks: [Task] = []

    func fetchTasks(completion: @escaping ([Task]) -> Void) {
        isFetchTasksCalled = true
        completion(tasks)
    }

    func startSpeechRecognition(completion: @escaping (Result<String, Error>) -> Void) {
        // Эмуляция успеха или ошибки распознавания речи
    }

    func stopSpeechRecognition() {
        // Ничего не делает
    }
}
