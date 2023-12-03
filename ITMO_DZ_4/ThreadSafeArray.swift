import Foundation

class ThreadSafeArray<T>  {
    private var array: [T]
    private var lock = RWLock()
    
    init(array: [T]) {
        self.array = array
    }
    
    init(size: Int, defaultValue: T) {
        self.array = Array(repeating: defaultValue, count: size)
    }
}

extension ThreadSafeArray: RandomAccessCollection {
    typealias Index = Int
    typealias Element = T

    var startIndex: Index {
        lock.readLock()
        defer { lock.unlock() }
        return array.startIndex
    }
    
    var endIndex: Index {
        lock.readLock()
        defer { lock.unlock() }
        return array.endIndex
    }

    subscript(index: Index) -> Element {
        
        get {
            lock.readLock()
            defer { lock.unlock() }
            return array[index]
        }
        
        set {
            lock.writeLock()
            defer { lock.unlock() }
            array[index] = newValue
        }
    }

    func index(after i: Index) -> Index {
        return array.index(after: i)
    }
    
    func append(_ newElement: T) {
        lock.writeLock()
        defer { lock.unlock() }
        array.append(newElement)
    }
    
    func remove(at: Int) -> T {
        lock.writeLock()
        defer { lock.unlock() }
        return array.remove(at: at)
    }
    
    func toString() -> String {
        lock.readLock()
        defer { lock.unlock() }
        return "\(array)"
    }
    
}


class RWLock {
    private var lock = pthread_rwlock_t()
    
    public init() {
        guard pthread_rwlock_init(&lock, nil) == 0 else {
            fatalError("cant create rwlock")
        }
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    @discardableResult
    func writeLock() -> Bool {
        pthread_rwlock_wrlock(&lock) == 0
    }
    
    @discardableResult
    func readLock() -> Bool {
        pthread_rwlock_rdlock(&lock) == 0
    }
    
    @discardableResult
    func unlock() -> Bool {
        pthread_rwlock_unlock(&lock) == 0
    }
}
