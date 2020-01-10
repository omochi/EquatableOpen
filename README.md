# EquatableOpen

You can open `Any` to `<T>` or `<T: Equatable>` by using runtime magic.

# API

## anyIsEqual

```swift
func anyIsEqual(_ a: Any, _ b: Any) -> Bool
```

It calls `==` if type of `a` and `b` are `Equatable`.
It returns `false` if not.

## openEquatable

```swift
public protocol EquatableOpener {
    init<T>(_ value: T)
    init<T: Equatable>(_ value: T)
}

func openEquatable<EO: EquatableOpener>(_ anyValue: Any, openerType: EO.Type) -> EO
```

You can open `Any`.
It calls corresponding `init` to whether type of `anyValue` is `Equatable`.

You can build `AnyEquatable`(see below) as custom implementation on it.

- https://github.com/kateinoigakukun/AnyEquatable
