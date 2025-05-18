import UIKit

final class TaskDetailsAssembly {
    static func build(with task: Task) -> UIViewController {
        let view = TaskDetailsViewController()
        let interactor = TaskDetailsInteractor(task: task)
        let router = TaskDetailsRouter(viewController: view)
        let presenter = TaskDetailsPresenter(
            view: view,
            interactor: interactor,
            router: router,
            task: task
        )
        view.presenter = presenter
        interactor.output = presenter
        return view
    }
}
