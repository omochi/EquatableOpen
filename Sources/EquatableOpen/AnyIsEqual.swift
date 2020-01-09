internal struct _AnyIsEqual: EquatableOpener {
    public var _isEqualTo: (Any) -> Bool
    
    public init<T>(_ value: T) {
        _isEqualTo = { (_) in false }
    }
    
    public init<T: Equatable>(_ left: T) {
        _isEqualTo = { (right) in
            guard let right = right as? T else { return false }
            return left == right
        }
    }
}

public func anyIsEqual(_ a: Any, _ b: Any) -> Bool {
    openEquatable(a, openerType: _AnyIsEqual.self)._isEqualTo(b)
}
