import UIKit

protocol TasksListRouterProtocol {
    func navigateToTaskDetails(with task: Task)
}

class TasksListRouter: TasksListRouterProtocol {
    weak var viewController: UIViewController?
    
    func navigateToTaskDetails(with task: Task) {
        guard let delegate = viewController as? TaskDetailsViewControllerDelegate else { return }
        let taskDetailsVC = TaskDetailsViewController(task: task, delegate: delegate)
        viewController?.navigationController?.pushViewController(taskDetailsVC, animated: true)
    }
}
