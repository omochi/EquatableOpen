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
    
    let EOType = EO.self
    
    guard let witnessTableOfEOForEquatableOpener = symbols
        .conformsToProtocol(type: EOType,
                            protocol: symbols.equatableOpenerProtocolDescriptor) else
    {
        preconditionFailure("witnessOfEOForEquatableOpener")
    }
    
    let openerRef = UnsafeMutablePointer<EO>.allocate(capacity: 1)
    defer {
        openerRef.deallocate()
    }
    
    let valueType = type(of: anyValueRef.pointee)
    
    let value = projectBoxedOpaqueExistential(existential: UnsafeRawPointer(anyValueRef),
                                              type: valueType)
    
    let witnessTableOfTForEquatable = symbols
        .conformsToProtocol(type: valueType,
                            protocol: symbols.equatableProtocolDescriptor)
    
    symbols.openEquatable(result: UnsafeMutableRawPointer(openerRef),
                          value: value,
                          valueType: valueType,
                          openerType: openerType,
                          witnessTableOfTForEquatable: witnessTableOfTForEquatable,
                          witnessTableOfEOForEquatableOpener: witnessTableOfEOForEquatableOpener)
    
    return openerRef.move()
}

@_silgen_name("swift_openEquatable_T")
public func _openEquatable<T, EO: EquatableOpener>(
    resultRef: UnsafeMutablePointer<EO>, value: T, openerType: EO.Type)
{
    resultRef.initialize(to: openerType.init(value))
}

@_silgen_name("swift_openEquatable_Equatable")
public func _openEquatable<T: Equatable, EO: EquatableOpener>(
    resultRef: UnsafeMutablePointer<EO>, value: T, openerType: EO.Type)
{
    resultRef.initialize(to: openerType.init(value))
}
