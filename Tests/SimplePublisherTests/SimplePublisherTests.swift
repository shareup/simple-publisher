import XCTest
@testable import SimplePublisher
import Forever

class Emitter: SimplePublisher {
    typealias Output = String
    typealias Failure = Never
    var subject = SimpleSubject<Output, Failure>()
    
    var timer: Timer?
    
    func start() {
        guard timer == nil else { return }
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: trigger(_:))
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

        let sub = emitter.forever { _ in
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

        let sub = emitter.forever { _ in
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

        let sub = emitter.forever { _ in
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
        
        let sub1 = emitter.sink { _ in
            sinkEx.fulfill()
        }
        defer { sub1.cancel() }
        
        let sub2 = emitter.forever { _ in
            foreverEx.fulfill()
        }
        defer { sub2.cancel() }
        
        waitForExpectations(timeout: 4.1)
    }
    
    func testEmitterHasDifferentSubscribersOverTime() {
        var emitter = Emitter()
        emitter.start()
        defer { emitter.stop() }
        
        let sink1Ex = expectation(description: "Sink1 should get 1 string only")
        let sink2Ex = expectation(description: "Sink2 should get 1 string only")
        let forever1Ex = expectation(description: "Forever1 should get 1 string only in about 2 seconds")
        let forever2Ex = expectation(description: "Forever2 should get 2 strings in about 4 seconds (not 3) since it starts late and shouldn't get historical items")
        forever2Ex.expectedFulfillmentCount = 2
        
        let sub1 = emitter.sink { _ in
            sink1Ex.fulfill()
        }
        
        let sub2 = emitter.forever { _ in
            forever1Ex.fulfill()
        }
        
        wait(for: [sink1Ex], timeout: 2.1)
        
        sub1.cancel()
        sub2.cancel()
        
        let sub3 = emitter.sink { _ in
            sink2Ex.fulfill()
        }
        defer { sub3.cancel() }
        
        let sub4 = emitter.forever { _ in
            forever2Ex.fulfill()
        }
        defer { sub4.cancel() }
        
        waitForExpectations(timeout: 4.1)
    }
}
