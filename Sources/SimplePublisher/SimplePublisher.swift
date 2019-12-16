import Foundation
import Combine

protocol SimplePublisher: Publisher {
    var coordinator: SimpleCoordinator<Output, Failure> { get }
}

extension SimplePublisher {
    public func receive<S>(subscriber: S)
        where S: Subscriber, Failure == S.Failure, Output == S.Input {

        coordinator.receive(subscriber: subscriber)
    }
}
