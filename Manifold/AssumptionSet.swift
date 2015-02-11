//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct AssumptionSet: DictionaryLiteralConvertible, SequenceType {
	public subscript(variable: Int) -> [Scheme] {
		get { return assumptions[variable] ?? [] }
		set { assumptions[variable] = self[variable] + newValue }
	}


	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (Int, [Scheme])...) {
		assumptions = [:] + elements
	}


	// MARK: SequenceType

	public func generate() -> GeneratorOf<(Int, [Scheme])> {
		return GeneratorOf(assumptions.generate())
	}


	// MARK: Private

	private var assumptions: [Int: [Scheme]]
}


public func + (left: AssumptionSet, right: AssumptionSet) -> AssumptionSet {
	var result = left
	for (variable, schemes) in right {
		result[variable] = result[variable] + schemes
	}
	return result
}
