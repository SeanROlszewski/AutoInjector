import XCTest
@testable import AutoInjector

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
   
    func testItAddsADependency() {
        let dependency = SomeStruct(string: "Test", integer: 5)
        
        subject.addDependency(forType: SomeStruct.self, withInstance: dependency)
        let expectedDependency = subject.getInstance(forType: SomeStruct.self)
        
        XCTAssertEqual(expectedDependency?.integer, dependency.integer)
        XCTAssertEqual(expectedDependency?.string, dependency.string)
    }
    
    func testItAddsAClassAsADependency() {
        let dependency = SomeClass(string: "AnotherTest", integer: 5)
        subject.addDependency(forType: SomeClass.self, withInstance: dependency)
        let expectedDependency = subject.getInstance(forType: SomeClass.self)
        XCTAssertEqual(expectedDependency?.integer, dependency.integer)
        XCTAssertEqual(expectedDependency?.string, dependency.string)
        XCTAssertFalse(expectedDependency === dependency)
    }

    func testItAddsADependencyWithAConfigurationRoutine() {
        subject.addDependency(forType: NSMutableURLRequest.self) {
            let req = NSMutableURLRequest(url: URL(string: "http://google.com")!)
            req.addValue("Test", forHTTPHeaderField: "Authorization")
            return req
        }
        
        let dependency = subject.getInstance(forType: NSMutableURLRequest.self)
        XCTAssertEqual(dependency?.allHTTPHeaderFields?["Authorization"], "Test")
        XCTAssertEqual(dependency?.url, URL(string: "http://google.com")!)
    }
    
    func testItReturnsNilForAnUnregisteredDependency() {
        XCTAssertNil(subject.getInstance(forType: SomeClass.self))
    }
    
    func testItRemovesADependency() {
        let dependency = SomeClass(string: "AnotherTest", integer: 5)
        subject.addDependency(forType: SomeClass.self, withInstance: dependency)
        subject.removeDependency(forType: SomeClass.self)
        XCTAssertNil(subject.getInstance(forType: SomeClass.self))
    }
    
    func testItRegistersASingleton() {
        let dependency = SomeClass(string: "AnotherTest", integer: 5)
        subject.addDependency(forType: SomeClass.self, withInstance: dependency, andScope: .singleton)
        
        let expectedDependency = subject.getInstance(forType: SomeClass.self)
        XCTAssertTrue(dependency === expectedDependency)
    }
    
    func testItMakesUniqueCopies() {
        let subject = SomeClass(string: "AnotherTest", integer: 5)
        let copy = subject.copy()
        
        XCTAssertEqual(subject.integer, copy.integer)
        XCTAssertEqual(subject.string, copy.string)
        XCTAssertFalse(subject === copy)
    }
}
