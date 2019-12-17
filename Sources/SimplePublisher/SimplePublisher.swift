import Foundation
import Combine

public class SimplePublisher<Output, Failure: Error>: Publisher {
    public typealias Output = Output
    public typealias Failure = Failure
    
    private let coordinator = SimpleCoordinator<Output, Failure>()
    
    public func receive<S>(subscriber: S)
        where S: Subscriber, Failure == S.Failure, Output == S.Input {

        coordinator.receive(subscriber: subscriber)
    }
    
    func publish(_ output: Output) {
        coordinator.receive(output)
    }
}
