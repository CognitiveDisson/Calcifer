import Foundation

public final class ThreadSafeDictionary<Key: Hashable, Value> {
    
    private let lock = NSRecursiveLock()
    private var dictionary = Dictionary<Key, Value>()
    
    private(set) lazy var read: (Key) -> (Value?) = { [weak self] key in
        self?.dictionary[key]
    }
    
    private(set) lazy var write: (Key, Value) -> () = { [weak self] key, value in
        guard let strongSelf = self else { return }
        // In this situation, it is more correct to use the DispatchQueue, not the lock,
        // because the queue guarantees the absence of a double write, but it works twice as long.
        // Performance is more important than this warranty, so I left the lock.
        strongSelf.lock.lock()
        strongSelf.dictionary[key] = value
        strongSelf.lock.unlock()
    }
    
    public var values: Array<Value> {
        return Array(dictionary.values)
    }
    
    init() {}
    
}
