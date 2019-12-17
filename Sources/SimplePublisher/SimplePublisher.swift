import Combine

public protocol SimplePublisher: Publisher {
    var subject: SimpleSubject<Output, Failure> { get }
    
    func publish(_ output: Output)
    func complete()
    func complete(_ failure: Failure)
    func complete(_ completion: Subscribers.Completion<Failure>)
}

extension SimplePublisher {
    public func receive<S>(subscriber: S)
        where S: Subscriber, Failure == S.Failure, Output == S.Input {
            subject.receive(subscriber: subscriber)
    }
    
    public func publish(_ output: Output) {
        subject.send(output)
    }
    
    public func complete() {
        complete(.finished)
    }
    
    public func complete(_ failure: Failure) {
        complete(.failure(failure))
    }
    
    public func complete(_ completion: Subscribers.Completion<Failure>) {
        subject.send(completion: completion)
    }
}
