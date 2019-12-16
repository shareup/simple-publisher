import Foundation
import Combine
import Synchronized

public final class SimpleCoordinator<Output, Failure: Error>: Publisher, Synchronized {
    var subscriptions: [SimpleSubscription<Output, Failure>] = []
    var isComplete = false
    var isIncomplete: Bool { return !isComplete }
    
    public init() {}
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        sync {
            guard isIncomplete else { return }
        }
        
        let subscription = SimpleSubscription(publisher: self.eraseToAnyPublisher(), subscriber: AnySubscriber(subscriber))
        subscriber.receive(subscription: subscription)
        
        sync {
            subscriptions.append(subscription)
        }
    }
    
    public func receive(_ output: Output) {
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
            
            self.subscriptions.removeAll()
            
            self.isComplete = true
        }
    }
    
    deinit {
        self.subscriptions.removeAll()
    }
}
