# SimplePublisher

⚠️⚠️⚠️ **ARCHIVED** ⚠️⚠️⚠️

This repository has been archived because its purpose is best served by using the default [`PassthroughSubject`](https://developer.apple.com/documentation/combine/passthroughsubject).

---

Very quickly give your struct or class the ability to publish out to subscribers by conforming to SimplePublisher.

## Installation

```swift
// swift-tools-version:5.1
// platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v5),],

.package(url: "https://github.com/shareup/simple-publisher.git", .upToNextMajor(from: "1.1.0")),
```

## A full usage example

Assuming one has a very simple periodic emitter: 

```swift
class Emitter {
    var timer: Timer?
    
    func start() {
        guard timer == nil else { return }
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: trigger(_:))
    }
    
    private func trigger(_ timer: Timer) {
        print("💡 \(UUID().uuidString)")
    }
    
    func stop() {
        timer?.invalidate()
        self.timer = nil
    }
    
    deinit {
        stop()
    }
}
```

one can turn it into a `SimplePublisher` by subclassing:

```swift
struct Emitter: SimplePublisher {
    typealias Output = String
    typealias Failure = Never
    var subject = SimpleSubject<Output, Failure>()
    
    // ...
    
    private func trigger(_ timer: Timer) {
        publish(UUID().uuidString)
    }
    
    // ...
}
```

The main concepts to know are:

* Publishers must indicate what the `Output` type is – what are you going to publish out for subscribers to receive?
* Publishers must indicate the type for `Failure` – what type of `Error` are you going to emit to subscribers when something goes wrong?
* Setup a `SimpleSubject` which takes care of all the `Subscriber` and `Subscription` bookeeping ⭐️

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
class Emitter: SimplePublisher {
    typealias Output = String
    typealias Failure = Never
    var subject = SimpleSubject<Output, Failure>()
    
    var timer: Timer?
    
    func start() {
        guard timer == nil else { return }
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: trigger(_:))
    }
    
    private func trigger(_ timer: Timer) {
        publish(UUID().uuidString)
    }
    
    func stop() {
        timer?.invalidate()
        self.timer = nil
    }
    
    deinit {
        stop()
    }
}

let emitter = Emitter()
emitter.start()

emitter.forever { print("Tick → \($0)") }
```
