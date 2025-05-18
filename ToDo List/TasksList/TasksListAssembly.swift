import UIKit

class TasksListAssembly {
    static func assembly() -> TasksListViewController {
        let networkService = NetworkService()
        let interactor = TasksListInteractor(networkService: networkService)
        let router = TasksListRouter()
        let presenter = TasksListPresenter(router: router, interactor: interactor)
        let view = TasksListViewController(presenter: presenter)
        
        presenter.view = view
        router.viewController = view
        
        return view
    }
}
