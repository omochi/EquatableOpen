#if os(macOS)
import Darwin

private let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: Int(-2))
#elseif os(Linux)
import Glibc

private let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: Int(0))
#endif


internal enum Dl {
    public static func dlerrorString() -> String? {
        guard let cstr = dlerror() else {
            return nil
        }
        return String(cString: cstr)
    }

    public static func sym<T>(_ name: String,
                              type: T.Type) throws -> T {
        guard let ptr = dlsym(RTLD_DEFAULT, name) else {
            var strs: [String] = [
                "symbol not found: \(name)"
            ]
            if let e = dlerrorString() {
                strs.append(e)
            }
            throw MessageError(strs.joined(separator: ", "))
        }
        return unsafeBitCast(ptr, to: type)
    }
}

