//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct AssumptionSet: DictionaryLiteralConvertible, Equatable, Printable, SequenceType {
	public subscript(variable: Int) -> [Type] {
		get { return assumptions[variable] ?? [] }
		set { assumptions[variable] = self[variable] + newValue }
	}


	public var count: Int {
		return assumptions.count
	}


	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (Int, [Type])...) {
		assumptions = [:] + elements
	}


	// MARK: Printable

	public var description: String {
		let s = lazy(assumptions)
			.map {
				let types = ", ".join(lazy($1).map(toString) |> sorted)
				return "\($0) ~ [ \(types) ]"
			}
			|> sorted
			|> (join <| "")
		return assumptions.count > 0 ?
			"{ \(s) }"
		:	"{}"
	}


	// MARK: SequenceType

	public func generate() -> GeneratorOf<(Int, [Type])> {
		return GeneratorOf(assumptions.generate())
	}


	// MARK: Private

	private var assumptions: [Int: [Type]]
}


public func == (left: AssumptionSet, right: AssumptionSet) -> Bool {
	return reduce(lazy(Set(left.assumptions.keys).union(right.assumptions.keys)).map { left[$0] == right[$0] }, true) { $0 && $1 }
}


public func + (var left: AssumptionSet, right: AssumptionSet) -> AssumptionSet {
	for (variable, schemes) in right {
		left[variable] = left[variable] + schemes
	}
	return left
}


public func / (var left: AssumptionSet, right: Int) -> AssumptionSet {
	left.assumptions.removeValueForKey(right)
	return left
}


// MARK: - Imports

import Prelude
