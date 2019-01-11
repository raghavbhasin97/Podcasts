import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupAppearance()
        loadMain()
        return true
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        API.shared.clearCache()
    }
    
    func loadMain() {
        let controller = Main()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }
    
    fileprivate func setupAppearance() {
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().tintColor = .purple
        UITabBar.appearance().unselectedItemTintColor = .lightGray
        UINavigationBar.appearance().prefersLargeTitles = true
    }
    

}

