# AutoInjector
A dead simple dependency injector in Swift

# Example

    private func registerDependencies() {
        injector.addDependency(for: Guitar.self, withInstance: Guitar(brand: "Gibson"))
        
        injector.addDependency(for: ViewController.self) {
            injector in
            let vc = ViewController(nibName: String.from(type: ViewController.self), bundle: nil)
            vc.guitar = injector.getInstance(for: Guitar.self)
            return vc
        }
    }
