import XCTest
@testable import AutoInjector

protocol SomeProtocol {
    func doSomethingGreat() -> String
}

struct SomeProtocolConformer: SomeProtocol {
    func doSomethingGreat() -> String {
        return "I did the thing!"
    }
}

struct SomeStruct {
    var string: String
    var integer: Int
}

class SomeClass: Copyable {
    var string: String
    var integer: Int
    
    required init(fromCopyOf anInstance: SomeClass){
        self.integer = anInstance.integer
        self.string = anInstance.string
    }

    init(string: String, integer: Int) {
        self.string = string
        self.integer = integer
    }
    
    func copy() -> Self {
        return type(of: self).init(fromCopyOf: self)
    }
}

class AutoInjectorTests: XCTestCase {
    var subject: Injector!
    
    override func setUp() {
        subject = Injector()
    }
   
    func testItAddsAStructAsDependency() {
        let dependency = SomeStruct(string: "Test", integer: 5)
        
        subject.addDependency(for: SomeStruct.self, withInstance: dependency)
        
        let expectedDependency = subject.getInstance(for: SomeStruct.self)
        XCTAssertEqual(expectedDependency?.integer, dependency.integer)
        XCTAssertEqual(expectedDependency?.string, dependency.string)
    }
    
    func testItAddsAClassAsADependency() {
        let dependency = SomeClass(string: "AnotherTest", integer: 5)
        
        subject.addDependency(for: SomeClass.self, withInstance: dependency)
        
        let expectedDependency = subject.getInstance(for: SomeClass.self)
        XCTAssertEqual(expectedDependency?.integer, dependency.integer)
        XCTAssertEqual(expectedDependency?.string, dependency.string)
        XCTAssertFalse(expectedDependency === dependency)
    }
    
    func testItAddsAProtocolAsADependency() {
        subject.addDependency(for: SomeProtocol.self) { _ in SomeProtocolConformer() }
        
        let expectedDependency = subject.getInstance(for: SomeProtocol.self)
        
        XCTAssertEqual(expectedDependency?.doSomethingGreat(), "I did the thing!")
    }

    func testItAddsADependencyWithAConfigurationRoutine() {
        subject.addDependency(for: NSMutableURLRequest.self) {
            _ in
            let req = NSMutableURLRequest(url: URL(string: "http://google.com")!)
            req.addValue("text/html", forHTTPHeaderField: "Content-Type")
            return req
        }
        
        let dependency = subject.getInstance(for: NSMutableURLRequest.self)
        let dependency2 = subject.getInstance(for: NSMutableURLRequest.self)
        
        XCTAssertEqual(dependency?.allHTTPHeaderFields?["Content-Type"], "text/html")
        XCTAssertEqual(dependency?.url, URL(string: "http://google.com")!)
        XCTAssertFalse(dependency === dependency2)
    }
    
    func testItReturnsNilForAnUnregisteredDependency() {
        XCTAssertNil(subject.getInstance(for: SomeClass.self))
    }
    
    func testItRemovesADependency() {
        let dependency = SomeClass(string: "AnotherTest", integer: 5)
        subject.addDependency(for: SomeClass.self, withInstance: dependency)
       
        subject.removeDependency(for: SomeClass.self)
        
        XCTAssertNil(subject.getInstance(for: SomeClass.self))
    }
    
    func testItRegistersASingleton() {
        let dependency = SomeClass(string: "AnotherTest", integer: 5)
        subject.addDependency(for: SomeClass.self, withInstance: dependency, andScope: .singleton)
        
        let expectedDependency = subject.getInstance(for: SomeClass.self)
        
        XCTAssertTrue(dependency === expectedDependency)
    }
    
    func testItHasCustomScopeRules() {
        var userIsLoggedIn = true
        let scopeRule = { userIsLoggedIn }
        
        let initialDependency = SomeClass(string: "AnotherTest", integer: 5)
        subject.addDependency(for: SomeClass.self, withInstance: initialDependency, andScope: .custom(rule: scopeRule))
        
        var expectedDependency = subject.getInstance(for: SomeClass.self)
        XCTAssertTrue(initialDependency === expectedDependency, "Expected the same instance")
        
        userIsLoggedIn = false
        expectedDependency = subject.getInstance(for: SomeClass.self)
        XCTAssertFalse(initialDependency === expectedDependency, "Expected a different instance")
    }
}

class SomeClassTests: XCTestCase {
    func testItMakesUniqueCopies() {
        let subject = SomeClass(string: "AnotherTest", integer: 5)
        let copy = subject.copy()
        
        XCTAssertEqual(subject.integer, copy.integer)
        XCTAssertEqual(subject.string, copy.string)
        XCTAssertFalse(subject === copy)
    }
}
