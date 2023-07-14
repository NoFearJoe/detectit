import SwiftUI
import Combine

@propertyWrapper
public struct PublishedAppStorage<Value> {

    public var wrappedValue: Value {
        get { storage.wrappedValue }
        set {
            storage.wrappedValue = newValue
            subject.send(storage.wrappedValue)
        }
    }

    public var projectedValue: Self {
        self
    }

    /// Provides access to ``AppStorage.projectedValue`` for binding purposes.
    public var binding: Binding<Value> {
        storage.projectedValue
    }

    /// Provides a ``Publisher`` for non view code to respond to value updates.
    private let subject: CurrentValueSubject<Value, Never>
    public var publisher: AnyPublisher<Value, Never> {
        subject.send(storage.wrappedValue)
        return subject.eraseToAnyPublisher()
    }

    private var storage: AppStorage<Value>

    public init(wrappedValue: Value, _ key: String) where Value == String {
        storage = AppStorage(wrappedValue: wrappedValue, key)
        subject = CurrentValueSubject<Value, Never>(wrappedValue)
    }

    public init(wrappedValue: Value, _ key: String) where Value: RawRepresentable, Value.RawValue == Int {
        storage = AppStorage(wrappedValue: wrappedValue, key)
        subject = CurrentValueSubject<Value, Never>(wrappedValue)
    }

    public init(wrappedValue: Value, _ key: String) where Value == Data {
        storage = AppStorage(wrappedValue: wrappedValue, key)
        subject = CurrentValueSubject<Value, Never>(wrappedValue)
    }

    public init(wrappedValue: Value, _ key: String) where Value == Int {
        storage = AppStorage(wrappedValue: wrappedValue, key)
        subject = CurrentValueSubject<Value, Never>(wrappedValue)
    }

    public init(wrappedValue: Value, _ key: String) where Value: RawRepresentable, Value.RawValue == String {
        storage = AppStorage(wrappedValue: wrappedValue, key)
        subject = CurrentValueSubject<Value, Never>(wrappedValue)
    }

    public init(wrappedValue: Value, _ key: String) where Value == URL {
        storage = AppStorage(wrappedValue: wrappedValue, key)
        subject = CurrentValueSubject<Value, Never>(wrappedValue)
    }

    public init(wrappedValue: Value, _ key: String) where Value == Double {
        storage = AppStorage(wrappedValue: wrappedValue, key)
        subject = CurrentValueSubject<Value, Never>(wrappedValue)
    }

    public init(wrappedValue: Value, _ key: String) where Value == Bool {
        storage = AppStorage(wrappedValue: wrappedValue, key)
        subject = CurrentValueSubject<Value, Never>(wrappedValue)
    }

    public mutating func update() {
        storage.update()
    }
}
