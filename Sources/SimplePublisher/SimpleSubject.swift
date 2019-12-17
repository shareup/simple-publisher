import Foundation
import Combine
import Synchronized

public class SimpleSubject<Output, Failure>: Publisher, Synchronized where Failure: Error {
    var subscriptions: [SimpleSubscription<Output, Failure>] = []
    var isComplete = false
    var isIncomplete: Bool { return !isComplete }
    
    public init() {}
    
    public func receive<S>(subscriber: S)
        where S: Subscriber, Failure == S.Failure, Output == S.Input {
            sync {
                guard isIncomplete else { return }
            }
            
            let subscription = SimpleSubscription(publisher: self, subscriber: subscriber)
            
            sync {
                subscriptions.append(subscription)
            }
            
            subscriber.receive(subscription: subscription)
    }
    
    public func publish(_ output: Output) {
        sync {
            guard isIncomplete else { return }
            
            for subscription in subscriptions {
                subscription.receive(output)
            }
        }
    }
    
    public func complete() {
        complete(.finished)
    }
    
    public func complete(_ failure: Failure) {
        complete(.failure(failure))
    }
    
    public func complete(_ completion: Subscribers.Completion<Failure>) {
        sync {
            guard isIncomplete else { return }
            
            for subscription in subscriptions {
                subscription.receive(completion: completion)
            }
            
            subscriptions.removeAll()
            
            self.isComplete = true
        }
    }
    
    deinit {
        subscriptions.removeAll()
    }
}
