public protocol EquatableOpener {
    init<T>(_ value: T)
    init<T: Equatable>(_ value: T)
}

public func openEquatable<EO: EquatableOpener>(_ value: Any, openerType: EO.Type) -> EO {
    let symbols = Symbols.shared
    
    let valueType = type(of: value)
    
    guard let witness = symbols.conformsToProtocol(type: valueType,
                                                   protocol: symbols.equatableProtocolDescriptor) else
    {
        
        let opener = UnsafeMutablePointer<EO>.allocate(capacity: 1)
        // initialized in generic function
        
        defer {
            opener.deinitialize(count: 1)
            opener.deallocate()
        }
        
        symbols.openEquatableT(result: UnsafeMutableRawPointer(opener,
                                                               value: <#T##UnsafeRawPointer#>,
                                                               openerType: <#T##Any.Type#>,
                                                               T: <#T##Any.Type#>,
                                                               EO: <#T##Any.Type#>,
                                                               witness_EO_EquatableOpener: <#T##UnsafeRawPointer#>)
        
    }
    
    
    // 黒魔術
    return openerType.init(value)
}

@_silgen_name("swift_openEquatable_T")
public func _openEquatable<T, EO: EquatableOpener>(_ value: T, openerType: EO.Type) -> EO {
    return openerType.init(value)
}

@_silgen_name("swift_openEquatable_Equatable")
public func _openEquatable<T: Equatable, EO: EquatableOpener>(_ value: T, openerType: EO.Type) -> EO {
    return openerType.init(value)
}
