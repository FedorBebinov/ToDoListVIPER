//
//  TasksListAssembly.swift
//  ToDo List
//
//  Created by Fedor Bebinov on 18.03.2025.
//

import UIKit

class TasksListAssembly {
    static func assembly() -> TasksListViewController {
        let speechService = SpeechRecognitionService()
        let networkService = NetworkService()
        let interactor = TasksListInteractor(speechService: speechService, networkService: networkService)
        let router = TasksListRouter()
        let presenter = TasksListPresenter(router: router, interactor: interactor)
        let view = TasksListViewController(presenter: presenter)
        
        presenter.view = view
        router.viewController = view
        
        return view
    }
}
