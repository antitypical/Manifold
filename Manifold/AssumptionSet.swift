//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct AssumptionSet: DictionaryLiteralConvertible, Equatable, SequenceType {
	public subscript(variable: Int) -> [Type] {
		get { return assumptions[variable] ?? [] }
		set { assumptions[variable] = self[variable] + newValue }
	}


	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (Int, [Type])...) {
		assumptions = [:] + elements
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
