import XCTest
@testable import SimplePublisher
import Forever

class Emitter: SimplePublisher<String, Never> {
    var timer: Timer?
    
    func start() {
        guard timer == nil else { return }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: trigger(_:))
        self.timer = timer
    }
    
    private func trigger(_ timer: Timer) {
        publish(UUID().uuidString)
    }
    
    func stop() {
        timer?.invalidate()
        self.timer = nil
    }
    
    deinit {
        stop()
    }
}

final class SimplePublisherTests: XCTestCase {
    func testEmitterEmits() {
        var emitter = Emitter()
        emitter.start()
        defer { emitter.stop() }
        
        let ex = expectation(description: "Should get a string in about 2 seconds")

        let sub = emitter.forever { string in
            ex.fulfill()
        }
        defer { sub.cancel() }
        
        waitForExpectations(timeout: 2.1)
    }
    
    func testEmitterEmitsTwice() {
        var emitter = Emitter()
        emitter.start()
        defer { emitter.stop() }
        
        let ex = expectation(description: "Should get a 2 strings in about 4 seconds")
        ex.expectedFulfillmentCount = 2

        let sub = emitter.forever { string in
            ex.fulfill()
        }
        defer { sub.cancel() }
        
        waitForExpectations(timeout: 4.1)
    }
    
    func testEmitterEmitsThrice() {
        var emitter = Emitter()
        emitter.start()
        defer { emitter.stop() }
        
        let ex = expectation(description: "Should get a 3 strings in about 6 seconds")
        ex.expectedFulfillmentCount = 3

        let sub = emitter.forever { string in
            ex.fulfill()
        }
        defer { sub.cancel() }
        
        waitForExpectations(timeout: 6.1)
    }
    
    func testEmitterHasTwoSubscribers() {
        var emitter = Emitter()
        emitter.start()
        defer { emitter.stop() }
        
        let sinkEx = expectation(description: "Sink should get 1 string only")
        let foreverEx = expectation(description: "Forever should get 2 strings in about 4 seconds")
        foreverEx.expectedFulfillmentCount = 2
        
        let sub1 = emitter.sink { string in
            sinkEx.fulfill()
        }
        defer { sub1.cancel() }
        
        let sub2 = emitter.forever { string in
            foreverEx.fulfill()
        }
        defer { sub2.cancel() }
        
        waitForExpectations(timeout: 4.1)
    }
}
