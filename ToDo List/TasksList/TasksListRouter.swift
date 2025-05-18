import UIKit

protocol TasksListRouterProtocol: AnyObject {
    func navigateToTaskDetails(with task: Task, delegate: TaskDetailsViewControllerDelegate?)
}

final class TasksListRouter: TasksListRouterProtocol {
    weak var viewController: UIViewController?

    func navigateToTaskDetails(with task: Task, delegate: TaskDetailsViewControllerDelegate?) {
        let detailVC = TaskDetailsViewController()
        let interactor = TaskDetailsInteractor(task: task)
        let detailRouter = TaskDetailsRouter(viewController: detailVC)
        let presenter = TaskDetailsPresenter(
            view: detailVC,
            interactor: interactor,
            router: detailRouter,
            task: task
        )
        detailVC.presenter = presenter
        detailVC.delegate = delegate
        interactor.output = presenter
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}
