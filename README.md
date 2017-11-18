# AutoInjector
A dead simple dependency injector in Swift with scoped bindings, ala [Blindside](https://github.com/jbsf/blindside)

# Example

```swift 
import UIKit
import AutoInjector

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var injector = Injector()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        registerDependencies()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = injector.getInstance(for: ViewController.self)
        window?.makeKeyAndVisible()

        return true
    }

    private func registerDependencies() {
        injector.addDependency(for: Guitar.self, withInstance: Guitar(brand: "Gibson"))

        injector.addDependency(for: ViewController.self) {
            injector in
            let vc = ViewController(nibName: String.from(type: ViewController.self), bundle: nil)
            vc.guitar = injector.getInstance(for: Guitar.self)
            return vc
        }
    }
}
```
