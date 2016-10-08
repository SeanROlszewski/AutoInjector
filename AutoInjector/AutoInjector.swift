import Foundation

protocol Copyable: class {
    init(fromCopyOf: Self)
    func copy() -> Self
}

enum InjectorScope {
    case newInstance
    case singleton
}

private func key<T: Any>(forType type: T.Type) -> String {
    return "\(type)"
}

class Injector {
    
    var dependencies = [String: Any]()
    
    func addDependency<T: Any>(forType type: T.Type, withInstance instance: T) {
        dependencies[key(forType: type)] = instance
    }
    
    func addDependency<T: Any>(forType type: T.Type, withConfig config: @escaping ()->T) {
        dependencies[key(forType: type)] = config
    }
    
    func getInstance<T: Any>(forType type: T.Type) -> T? {
        
        if let dependency = dependencies[key(forType: type)] as? T {
            return dependency
        } else if let config = dependencies[key(forType: type)] as? ()->T {
            return config()
        }
        
        return nil
    }
    
    func removeDependency<T: Any>(forType type: T.Type) {
        _ = dependencies.removeValue(forKey: key(forType: type))
    }
}

extension Injector {
    
    func addDependency<T: Copyable>(forType type: T.Type, withInstance instance: T) {
        addDependency(forType: type, withInstance: instance, andScope: .newInstance)
    }
    
    func addDependency<T: Copyable>(forType type: T.Type, withInstance instance: T, andScope scope: InjectorScope) {
        dependencies[key(forType: type)] = (type: type, instance: instance, scope: scope)
    }
    
    func getInstance<T: Copyable>(forType type: T.Type) -> T? {
        
        if let dependency = dependencies[key(forType: type)] as? T {
            return dependency
        } else if let config = dependencies[key(forType: type)] as? ()->T {
            return config()
        } else if let definition = dependencies[key(forType: type)] as? (type: T.Type, instance: T, scope: InjectorScope) {
            if definition.scope == .newInstance {
                return definition.instance.copy()
            } else {
                return definition.instance
            }
        }
        
        return nil
    }
}
