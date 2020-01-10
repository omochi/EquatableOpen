import Foundation

typealias ConformsToProtocolRuntimeFunction = @convention(c) (UnsafeRawPointer, UnsafeRawPointer) -> UnsafeRawPointer?

typealias OpenEquatableTFunction = @convention(c) (
    UnsafeMutableRawPointer,
    UnsafeRawPointer,
    UnsafeRawPointer,
    UnsafeRawPointer,
    UnsafeRawPointer,
    UnsafeRawPointer
) -> Void

typealias OpenEquatableEquatableFunction = @convention(c) (
    UnsafeMutableRawPointer,
    UnsafeRawPointer,
    UnsafeRawPointer,
    UnsafeRawPointer,
    UnsafeRawPointer,
    UnsafeRawPointer,
    UnsafeRawPointer
) -> Void

internal struct Symbols {
    public var equatableProtocolDescriptor: UnsafeMutableRawPointer
    public var equatableOpenerProtocolDescriptor: UnsafeMutableRawPointer
    
    private var _conformsToProtocol: ConformsToProtocolRuntimeFunction
    
    private var _openEquatableT: OpenEquatableTFunction
    private var _openEquatableEquatable: OpenEquatableEquatableFunction
    
    public init() throws {
        equatableProtocolDescriptor = try Dl.sym("$sSQMp", type: UnsafeMutableRawPointer.self)
        equatableOpenerProtocolDescriptor = try Dl.sym("$s13EquatableOpen0A6OpenerMp", type: UnsafeMutableRawPointer.self)
        _conformsToProtocol = try Dl.sym("swift_conformsToProtocol",
                                         type: ConformsToProtocolRuntimeFunction.self)
        _openEquatableT = try Dl.sym("swift_openEquatable_T",
                                     type: OpenEquatableTFunction.self)
        _openEquatableEquatable = try Dl.sym("swift_openEquatable_Equatable",
                                             type: OpenEquatableEquatableFunction.self)
    }
    
    public func conformsToProtocol(type: Any.Type, protocol proto: UnsafeRawPointer) -> UnsafeRawPointer? {
        return _conformsToProtocol(unsafeBitCast(type, to: UnsafeRawPointer.self),
                                   proto)
    }
    
    public func openEquatable(result: UnsafeMutableRawPointer,
                              value: UnsafeRawPointer,
                              valueType: Any.Type,
                              openerType: Any.Type,
                              witnessTableOfTForEquatable: UnsafeRawPointer?,
                              witnessTableOfEOForEquatableOpener: UnsafeRawPointer)
    {
        let valueType = unsafeBitCast(valueType, to: UnsafeRawPointer.self)
        let openerType = unsafeBitCast(openerType, to: UnsafeRawPointer.self)
        
        if let witnessTableOfTForEquatable = witnessTableOfTForEquatable {
            _openEquatableEquatable(result,
                                    value,
                                    openerType,
                                    valueType,
                                    openerType,
                                    witnessTableOfTForEquatable,
                                    witnessTableOfEOForEquatableOpener)
        } else {
            _openEquatableT(result,
                            value,
                            openerType,
                            valueType,
                            openerType,
                            witnessTableOfEOForEquatableOpener)
        }
    }
    
    public static let shared = try! Symbols()
}

