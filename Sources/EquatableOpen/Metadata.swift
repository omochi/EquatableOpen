internal struct RefCountedStruct {
    public var metadataPointer: UnsafeRawPointer
    public var counter: UnsafeRawPointer
}

internal enum ValueWitnessTable {
    public enum Offsets {
        public static let f0 = 0
        public static let f1 = f0 + 8
        public static let f2 = f1 + 8
        public static let f3 = f2 + 8
        public static let f4 = f3 + 8
        public static let f5 = f4 + 8
        public static let f6 = f5 + 8
        public static let f7 = f6 + 8
        public static let size = f7 + 8
        public static let stride = size + 8
        public static let flags = stride + 8
    }
    
    public struct Flags {
        public var value: UInt32
        
        public init(_ value: UInt32) {
            self.value = value
        }
        
        public var isInline: Bool {
            (value & Self.isNonInlineBit) == 0
        }
        
        public var alignmentMask: UInt {
            UInt(value & Self.alignmentMaskBitMask)
        }
        
        public static let alignmentMaskBitMask: UInt32 = 0x000000FF
        public static let isNonInlineBit: UInt32 = 0x00020000
    }
}

// see getProjectBoxedOpaqueExistentialFunction in lib/IRGen/GenExistential.cpp
internal func projectBoxedOpaqueExistential(existential: UnsafeRawPointer,
                                            type typeType: Any.Type) -> UnsafeRawPointer
{
    let type: UnsafeRawPointer = unsafeBitCast(typeType, to: UnsafeRawPointer.self)
    let vwtRawPtr: UnsafeRawPointer = type.assumingMemoryBound(to: UnsafeRawPointer.self).advanced(by: -1).pointee
    let vwtPtr = vwtRawPtr.assumingMemoryBound(to: UInt8.self)
    let flagsRawPtr: UnsafeRawPointer = UnsafeRawPointer(vwtPtr.advanced(by: ValueWitnessTable.Offsets.flags))
    let flagsRef = flagsRawPtr.assumingMemoryBound(to: UInt32.self)
    let flags = ValueWitnessTable.Flags(flagsRef.pointee)
    if flags.isInline {
        return existential
    }
    
    let boxAddress: UInt = existential.assumingMemoryBound(to: UInt.self).pointee
    
    let alignmentMask = flags.alignmentMask
    
    //  StartOffset = ((sizeof(HeapObject) + align) & ~align)
    let heapHeaderSize = UInt(MemoryLayout<RefCountedStruct>.size)
    let offset = (heapHeaderSize + alignmentMask) & ~alignmentMask
    
    return UnsafeRawPointer(bitPattern: boxAddress + offset)!
}
