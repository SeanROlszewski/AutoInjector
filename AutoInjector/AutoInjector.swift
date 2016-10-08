import Foundation

public protocol Copyable: class {
    init(fromCopyOf: Self)
    func copy() -> Self
}

public enum InjectorScope {
    case newInstance
    case singleton
    case custom(rule: ()->Bool)
}

public extension String {
    public static func from<T: Any>(type: T.Type) -> String {
        return "\(type)"
    }
}

public class Injector {
    
    var dependencies: [String: Any]
    
    public init() {
        dependencies = [String: Any]()
    }
    
    public func addDependency<T: Any>(for type: T.Type, withInstance instance: T) {
        dependencies[String.from(type: type)] = instance
    }
    
    public func addDependency<T: Any>(for type: T.Type, withConfig config: @escaping (Injector)->T) {
        dependencies[String.from(type: type)] = config
    }
    
    public func getInstance<T: Any>(for type: T.Type) -> T? {
        
        if let dependency = dependencies[String.from(type: type)] as? T {
            return dependency
        } else if let config = dependencies[String.from(type: type)] as? (Injector)->T {
            return config(self)
        }
        
        return nil
    }
    
    public func removeDependency<T: Any>(for type: T.Type) {
        _ = dependencies.removeValue(forKey: String.from(type: type))
    }
}

// MARK: Class injection methods

extension Injector {
    
    public func addDependency<T: Copyable>(for type: T.Type, withInstance instance: T) {
        addDependency(for: type, withInstance: instance, andScope: .newInstance)
    }
    
    public func addDependency<T: Copyable>(for type: T.Type, withInstance instance: T, andScope scope: InjectorScope) {
        dependencies[String.from(type: type)] = (instance: instance, scope: scope)
    }
    
    public func getInstance<T: Copyable>(for type: T.Type) -> T? {
        
        if let config = dependencies[String.from(type: type)] as? ()->T {
            return config()
        } else if let dependency = dependencies[String.from(type: type)] as? (instance: T, scope: InjectorScope) {
            
            switch dependency.scope {
            case .singleton:
                return dependency.instance
            case .newInstance:
                return dependency.instance.copy()
            case let .custom(rule):
                return rule() ? dependency.instance : dependency.instance.copy()
            }
        }
        
        return nil
    }
}
