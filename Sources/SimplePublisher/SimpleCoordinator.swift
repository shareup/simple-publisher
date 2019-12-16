import Foundation
import Combine
import Synchronized

final class SimpleCoordinator<Output, Failure: Error>: Publisher, Synchronized {
    var subscriptions: [SimpleSubscription<Output, Failure>] = []
    var isComplete = false
    var isIncomplete: Bool { return !isComplete }
    
    init() {}
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        sync {
            guard isIncomplete else { return }
        }
        
        let subscription = SimpleSubscription(publisher: self.eraseToAnyPublisher(), subscriber: AnySubscriber(subscriber))
        subscriber.receive(subscription: subscription)
        
        sync {
            subscriptions.append(subscription)
        }
    }
    
    func receive(_ output: Output) {
        sync {
            guard isIncomplete else { return }
            
            for subscription in subscriptions {
                subscription.receive(output)
            }
        }
    }
    
    func complete() {
        complete(.finished)
    }
    
    func complete(_ failure: Failure) {
        complete(.failure(failure))
    }
    
    func complete(_ completion: Subscribers.Completion<Failure>) {
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
