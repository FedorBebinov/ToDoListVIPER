import UIKit

protocol TaskDetailsRouterProtocol: AnyObject {
    func closeDetails()
    func open(with task: Task, delegate: TaskDetailsViewControllerDelegate?)
}

final class TaskDetailsRouter: TaskDetailsRouterProtocol {
    weak var viewController: UIViewController?

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func closeDetails() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func open(with task: Task, delegate: TaskDetailsViewControllerDelegate?) {
        let detailVC = TaskDetailsViewController()
        let interactor = TaskDetailsInteractor(task: task)
        let presenter = TaskDetailsPresenter(
            view: detailVC,
            interactor: interactor,
            router: self,
            task: task
        )
        detailVC.presenter = presenter
        detailVC.delegate = delegate 
        interactor.output = presenter
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}
