internal func equal<T>(
    _ expectedValue: T?,
    by areEquivalent: @escaping (T, T) -> Bool
) -> Predicate<T> {
    return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (nil, _?):
            return PredicateResult(status: .fail, message: msg.appendedBeNilHint())
        case (_, nil):
            return PredicateResult(status: .fail, message: msg)
        case (let expected?, let actual?):
            let matches = areEquivalent(expected, actual)
            return matches ? PredicateResult(bool: matches, message: msg) :
                PredicateResult(bool: matches, message: .fail(diff(expected, actual).joined(separator: "\n")))
        }
    }
}

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T: Equatable>(_ expectedValue: T) -> Predicate<T> {
    equal(expectedValue as T?)
}

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T: Equatable>(_ expectedValue: T?) -> Predicate<T> {
    equal(expectedValue, by: ==)
}

/// A Nimble matcher allowing comparison of collection with optional type
public func equal<T: Equatable>(_ expectedValue: [T?]) -> Predicate<[T?]> {
    return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(
                status: .fail,
                message: msg.appendedBeNilHint()
            )
        }

        let matches = expectedValue == actualValue
        return matches ? PredicateResult(bool: matches, message: msg) :
            PredicateResult(bool: matches, message: .fail(diff(expectedValue, actualValue).joined(separator: "\n")))
    }
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T>(_ expectedValue: Set<T>) -> Predicate<Set<T>> {
    return equal(expectedValue as Set<T>?)
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T>(_ expectedValue: Set<T>?) -> Predicate<Set<T>> {
    return equal(expectedValue, stringify: { stringify($0) })
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T: Comparable>(_ expectedValue: Set<T>) -> Predicate<Set<T>> {
    return equal(expectedValue as Set<T>?)
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T: Comparable>(_ expectedValue: Set<T>?) -> Predicate<Set<T>> {
    return equal(expectedValue, stringify: { set in
        stringify(set.map { Array($0).sorted(by: <) })
    })
}

private func equal<T>(_ expectedValue: Set<T>?, stringify: @escaping (Set<T>?) -> String) -> Predicate<Set<T>> {
    return Predicate { actualExpression in
        let actualValue = try actualExpression.evaluate()

        if expectedValue == actualValue {
            return PredicateResult(
                status: .matches,
                message: .expectedCustomValueTo(
                    "equal <\(stringify(expectedValue))>",
                    actual: "<\(stringify(actualValue))>"
                )
            )
        }

        return  PredicateResult(
            status: .doesNotMatch,
            message: .fail(diff(expectedValue, actualValue).joined(separator: "\n"))
        )
    }
}

public func ==<T: Equatable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(equal(rhs))
}

public func ==<T: Equatable>(lhs: Expectation<T>, rhs: T?) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable>(lhs: Expectation<T>, rhs: T) {
    lhs.toNot(equal(rhs))
}

public func !=<T: Equatable>(lhs: Expectation<T>, rhs: T?) {
    lhs.toNot(equal(rhs))
}

public func == <T>(lhs: Expectation<Set<T>>, rhs: Set<T>) {
    lhs.to(equal(rhs))
}

public func == <T>(lhs: Expectation<Set<T>>, rhs: Set<T>?) {
    lhs.to(equal(rhs))
}

public func != <T>(lhs: Expectation<Set<T>>, rhs: Set<T>) {
    lhs.toNot(equal(rhs))
}

public func != <T>(lhs: Expectation<Set<T>>, rhs: Set<T>?) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Comparable>(lhs: Expectation<Set<T>>, rhs: Set<T>) {
    lhs.to(equal(rhs))
}

public func ==<T: Comparable>(lhs: Expectation<Set<T>>, rhs: Set<T>?) {
    lhs.to(equal(rhs))
}

public func !=<T: Comparable>(lhs: Expectation<Set<T>>, rhs: Set<T>) {
    lhs.toNot(equal(rhs))
}

public func !=<T: Comparable>(lhs: Expectation<Set<T>>, rhs: Set<T>?) {
    lhs.toNot(equal(rhs))
}

#if canImport(Darwin)
import class Foundation.NSObject

extension NMBPredicate {
    @objc public class func equalMatcher(_ expected: NSObject) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            return try equal(expected).satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
