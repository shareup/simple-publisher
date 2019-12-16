# SimplePublisher for Combine

Very quickly give your struct or class the ability to publish out to subscribers.

## Installation

```swift
.package(url: "https://github.com/shareup/simple-publisher.git", .upToNextMajor(from: "1.0.0")),
```

or with more details about platforms and swift tools needed:

```swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v5),
    ],
    dependencies: [
        .package(url: "https://github.com/shareup/simple-publisher.git", .upToNextMajor(from: "1.0.0")),
    ],
)
```

## A full usage example

Assuming one has a very simple periodic emitter: 

```swift
struct Emitter {
    var timer: Timer?
    
    mutating func start() {
        guard timer == nil else { return }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: trigger(_:))
        self.timer = timer
    }
    
    private func trigger(_ timer: Timer) {
        print("💡 \(UUID().uuidString)")
    }
    
    mutating func stop() {
        timer?.invalidate()
        self.timer = nil
    }
}
```

one can turn it into a `SimplePublisher` by conforming to the protocol:

```swift
struct Emitter: SimplePublisher {
    typealias Output = String
    typealias Failure = Never
    var coordinator = SimpleCoordinator<Output, Failure>()
    
    private func trigger(_ timer: Timer) {
        coordinator.receive(UUID().uuidString)
    }
}
```

The main concepts to know are:

* Publishers must indicate what the `Output` type is – what are you going to publish out for subscribers to receive?
* Publisher must indicate the type for `Failure` – what type of `Error` are you going to emit to subscribers when something goes wrong?
* `SimplePublisher` needs one to setup a `SimpleCoordinator` which takes care of managing `Subscriber`s and `Subscription`s and all the bookeeping – ⭐️ no need to worry about it

### Subscribing

One can use `sink` or any other subscribers like [`forever`](https://github.com/shareup/forever):

```swift
let emitter = Emitter()
emitter.start()
emitter.sink { print("Sinked \($0)") } // will print once
emitter.forever { print("Tick → \($0)") } // will print over and over assuming forever is setup as a dependency
```

### Things to remember

`Combine` doesn't clean up `Subscriber`s for you, you need to cancel them or cancel the `Subscription` (especially in tests):

```swift
let subscriber = emitter.sink { print("Yo \($0)") }
defer { subscriber.cancel() }
```

See the [tests in this repo](https://github.com/shareup/simple-publisher/blob/master/Tests/SimplePublisherTests/SimplePublisherTests.swift) for more examples.

### Full example all together

```swift
struct Emitter: SimplePublisher {
    var timer: Timer?
    typealias Output = String
    typealias Failure = Never
    var coordinator = SimpleCoordinator<Output, Failure>()
    
    mutating func start() {
        guard timer == nil else { return }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: trigger(_:))
        self.timer = timer
    }
    
    private func trigger(_ timer: Timer) {
        coordinator.receive(UUID().uuidString)
    }
    
    mutating func stop() {
        coordinator.complete()
        timer?.invalidate()
        self.timer = nil
    }
}

let emitter = Emitter()
emitter.start()

emitter.forever { print("Tick → \($0)") }
```
