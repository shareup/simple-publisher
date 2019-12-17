import Foundation
import Combine

public protocol SimplePublisher: Publisher {
    var coordinator: PassthroughSubject<Output, Failure> { get }
}

extension SimplePublisher {
    public func receive<S>(subscriber: S)
        where S: Subscriber, Failure == S.Failure, Output == S.Input {
        coordinator.receive(subscriber: subscriber)
    }
}
