public protocol EquatableOpener {
    init<T>(_ value: T)
    init<T: Equatable>(_ value: T)
}

public func openEquatable<EO: EquatableOpener>(_ anyValue: Any, openerType: EO.Type) -> EO {
    var anyValue = anyValue
    return withUnsafePointer(to: &anyValue) { (anyValueRef) in
        return openEquatable(anyValueRef: anyValueRef, openerType: openerType)
    }
}

private func openEquatable<EO: EquatableOpener>(anyValueRef: UnsafePointer<Any>, openerType: EO.Type) -> EO {
    let symbols = Symbols.shared
    
    let openerRef = UnsafeMutablePointer<EO>.allocate(capacity: 1)
    defer {
        openerRef.deallocate()
    }
    
    let valueType = type(of: anyValueRef.pointee)
    
    guard let witness = symbols.conformsToProtocol(type: valueType,
                                                   protocol: symbols.equatableProtocolDescriptor) else
    {
        let value = projectBoxedOpaqueExistential(existential: UnsafeRawPointer(anyValueRef),
                                                  type: valueType)
        symbols.openEquatableT(result: UnsafeMutableRawPointer(openerRef),
                               value: value,
                               openerType: openerType,
                               T: valueType,
                               EO: openerType,
                               witness_EO_EquatableOpener: UnsafeRawPointer(bitPattern: 0x8)!)
        defer {
            openerRef.deinitialize(count: 1)
        }
        
        return openerRef.pointee
    }
    
    // 黒魔術
    return openerType.init(anyValueRef.pointee)
}

@_silgen_name("swift_openEquatable_T")
public func _openEquatable<T, EO: EquatableOpener>(_ value: T, openerType: EO.Type) -> EO {
    return openerType.init(value)
}

@_silgen_name("swift_openEquatable_Equatable")
public func _openEquatable<T: Equatable, EO: EquatableOpener>(_ value: T, openerType: EO.Type) -> EO {
    return openerType.init(value)
}
