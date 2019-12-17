import Foundation
import Combine
import Synchronized

public class SimpleSubscription<Item, Failure: Error>: Subscription, Synchronized {
    var publisher: AnyPublisher<Item, Failure>?
    var subscriber: AnySubscriber<Item, Failure>?
    var demand: Subscribers.Demand?
    
    init<P, S>(publisher: P, subscriber: S) where S: Subscriber, Failure == S.Failure, Item == S.Input, P: Publisher, Failure == P.Failure, Item == P.Output {
        self.publisher = AnyPublisher(publisher)
        self.subscriber = AnySubscriber(subscriber)
    }
    
    func receive(_ item: Item) {
        sync {
            guard let demand = demand else { return }
            guard demand > 0 else { return }
            guard let subscriber = subscriber else { return }
            
            let newDemand = subscriber.receive(item)
            self.demand = newDemand
        }
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        sync {
            subscriber?.receive(completion: completion)
            self.publisher = nil
            self.subscriber = nil
        }
    }
    
    public func request(_ newDemand: Subscribers.Demand) {
        sync {
            guard let previousDemand = self.demand else {
                self.demand = newDemand
                return
            }

            self.demand = previousDemand + newDemand
        }
    }
    
    public func cancel() {
        sync {
            self.publisher = nil
            self.subscriber = nil
        }
    }
    
    deinit {
        self.publisher = nil
        self.subscriber = nil
    }
}
