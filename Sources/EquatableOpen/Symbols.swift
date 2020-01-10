import Foundation

private func dlerrorString() -> String? {
    guard let cstr = Darwin.dlerror() else {
        return nil
    }
    return String(cString: cstr)
}

private let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: Int(-2))

private func dlsym(_ name: String) throws -> UnsafeMutableRawPointer {
    guard let ptr = Darwin.dlsym(RTLD_DEFAULT, name) else {
        var strs: [String] = [
            "symbol not found: \(name)"
        ]
        if let e = dlerrorString() {
            strs.append(e)
        }
        throw MessageError(strs.joined(separator: ", "))
    }
    return ptr
}

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
        equatableProtocolDescriptor = try dlsym("$sSQMp")
        equatableOpenerProtocolDescriptor = try dlsym("$s13EquatableOpen0A6OpenerMp")
        
        _conformsToProtocol = try unsafeBitCast(dlsym("swift_conformsToProtocol"),
                                                to: ConformsToProtocolRuntimeFunction.self)
        _openEquatableT = try unsafeBitCast(dlsym("swift_openEquatable_T"),
                                            to: OpenEquatableTFunction.self)
        _openEquatableEquatable = try unsafeBitCast(dlsym("swift_openEquatable_Equatable"),
                                                    to: OpenEquatableEquatableFunction.self)
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

