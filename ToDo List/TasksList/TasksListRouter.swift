//
//  TasksListRouter.swift
//  ToDo List
//
//  Created by Fedor Bebinov on 18.03.2025.
//

import UIKit

protocol TasksListRouterProtocol {
    func navigateToTaskDetails(with task: Task)
}

class TasksListRouter: TasksListRouterProtocol {
    weak var viewController: UIViewController?

        func navigateToTaskDetails(with task: Task) {
            //let taskDetailsVC = TaskDetailsViewController(task: task) // Экран с информацией о задаче
            //viewController?.navigationController?.pushViewController(taskDetailsVC, animated: true)
        }
}
