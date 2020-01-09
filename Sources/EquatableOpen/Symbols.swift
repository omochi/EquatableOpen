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

internal struct Symbols {
    private var _conformsToProtocol: ConformsToProtocolRuntimeFunction
    public var equatableProtocolDescriptor: UnsafeMutableRawPointer
    private var _openEquatableT: OpenEquatableTFunction
    public var openEquatableEquatable: UnsafeMutableRawPointer
    public init() throws {
        _conformsToProtocol = try unsafeBitCast(dlsym("swift_conformsToProtocol"),
                                                to: ConformsToProtocolRuntimeFunction.self)
        equatableProtocolDescriptor = try dlsym("$sSQMp")
        _openEquatableT = try unsafeBitCast(dlsym("swift_openEquatable_T"),
                                            to: OpenEquatableTFunction.self)
        openEquatableEquatable = try dlsym("swift_openEquatable_Equatable")
    }
    
    public func conformsToProtocol(type: Any.Type, protocol proto: UnsafeRawPointer) -> UnsafeRawPointer? {
        return _conformsToProtocol(unsafeBitCast(type, to: UnsafeRawPointer.self),
                                   proto)
    }
    
    public func openEquatableT(result: UnsafeMutableRawPointer,
                               value: UnsafeRawPointer,
                               openerType: Any.Type,
                               T: Any.Type,
                               EO: Any.Type,
                               witness_EO_EquatableOpener: UnsafeRawPointer)
    {
        _openEquatableT(result,
                        value,
                        unsafeBitCast(openerType, to: UnsafeRawPointer.self),
                        unsafeBitCast(T, to: UnsafeRawPointer.self),
                        unsafeBitCast(EO, to: UnsafeRawPointer.self),
                        witness_EO_EquatableOpener)
    }
    
    public static let shared = try! Symbols()
}

