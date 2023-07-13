import Foundation

public protocol Storage {
    func get<T>(key: String) -> T?
    func getDecodable<T: Decodable>(key: String) -> T?
    func save<T>(_ value: T?, key: String)
    func saveEncodable<T: Encodable>(_ value: T?, key: String)
}

extension Keychain: Storage {
    public func get<T>(key: String) -> T? {
        func getString() -> String? {
            Self.read(key).flatMap { String(data: $0, encoding: .utf8) }
        }
        
        switch T.self {
        case is String.Type:
            return getString() as? T
        case is Int.Type:
            return getString().map { Int($0) } as? T
        case is Double.Type:
            return getString().map { Double($0) } as? T
        case is Bool.Type:
            switch getString() {
            case "true":
                return true as? T
            case "false":
                return false as? T
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public func getDecodable<T: Decodable>(key: String) -> T? {
        Self.read(key).flatMap {
            try? JSONDecoder().decode(T.self, from: $0)
        }
    }
    
    public func save<T>(_ value: T?, key: String) {
        switch value {
        case let value as String:
            guard let data = value.data(using: .utf8) else { return }
            
            Self.save(key, value: data)
        case let value as Int:
            guard let data = String(value).data(using: .utf8) else { return }
            
            Self.save(key, value: data)
        case let value as Double:
            guard let data = String(value).data(using: .utf8) else { return }
            
            Self.save(key, value: data)
        case let value as Bool:
            guard let data = String(value).data(using: .utf8) else { return }
            
            Self.save(key, value: data)
        case nil:
            Self.delete(key)
        default:
            assertionFailure("Unsupported type \(T.self)")
        }
    }
    
    public func saveEncodable<T: Encodable>(_ value: T?, key: String) {
        guard let value else {
            return Self.delete(key)
        }
        guard let data = try? JSONEncoder().encode(value) else {
            return assertionFailure("Can't decode the value \(value)")
        }
        
        Self.save(key, value: data)
    }
}

extension UserDefaults: Storage {
    public func get<T>(key: String) -> T? {
        object(forKey: key) as? T
    }
    
    public func getDecodable<T: Decodable>(key: String) -> T? {
        guard let data = self.object(forKey: key) as? Data else { return nil }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    public func save<T>(_ value: T?, key: String) {
        set(value, forKey: key)
    }
    
    public func saveEncodable<T: Encodable>(_ value: T?, key: String) {
        guard let data = try? JSONEncoder().encode(value) else {
            return
        }
        
        set(data, forKey: key)
    }
}
