import Foundation
import Combine
import Synchronized

final class SimpleSubscription<Item, Failure: Error>: Subscription, Synchronized {
    var publisher: AnyPublisher<Item, Failure>?
    var subscriber: AnySubscriber<Item, Failure>?
    var demand: Subscribers.Demand?
    
    init(publisher: AnyPublisher<Item, Failure>, subscriber: AnySubscriber<Item, Failure>) {
        self.publisher = publisher
        self.subscriber = subscriber
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
    
    func request(_ newDemand: Subscribers.Demand) {
        sync {
            guard let previousDemand = self.demand else {
                self.demand = newDemand
                return
            }

            if newDemand == 0 {
                self.demand = newDemand
            } else {
                self.demand = previousDemand + newDemand
            }
        }
    }
    
    func cancel() {
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
