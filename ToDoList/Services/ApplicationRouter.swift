
import UIKit

final class ApplicationRouter {
    private var transitionHandler: UIViewController!

    func setup(_ window: UIWindow?) {
        guard let window = window else { return }
        transitionHandler = UIViewController()
        window.backgroundColor = .black
        window.overrideUserInterfaceStyle = .light
        window.rootViewController = transitionHandler
        window.makeKeyAndVisible()
        
        presentMainViewController()
    }

    public func presentMainViewController() {
        let mainVC = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainVC)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        
        transitionHandler.present(navigationController, animated: true)
    }
}

