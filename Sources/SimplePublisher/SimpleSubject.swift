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
            let isIncomplete = sync { return self.isIncomplete }
            guard isIncomplete else { return }
            
            let subscription = SimpleSubscription(publisher: self, subscriber: subscriber)
            
            send(subscription: subscription)
            
            subscriber.receive(subscription: subscription)
    }
    
    public func send(_ output: Output) {
        sync {
            guard isIncomplete else { return }
            
            for subscription in subscriptions {
                subscription.receive(output)
            }
        }
    }
    
    public func send(subscription: SimpleSubscription<Output, Failure>) {
        sync {
            subscriptions.append(subscription)
        }
    }

    public func send(completion: Subscribers.Completion<Failure>) {
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

extension SimpleSubject where SimpleSubject.Output == Void {
    public func send() {
        send(())
    }
}
