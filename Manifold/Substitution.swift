//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Substitution: DictionaryLiteralConvertible, Equatable {
	public init(_ elements: [Variable: Type]) {
		self.elements = elements
	}


	public func compose(other: Substitution) -> Substitution {
		return Substitution(other.elements + elements)
	}

	public var variables: Set<Variable> {
		return Set(elements.keys)
	}

	public var occurringVariables: Set<Variable> {
		let replacementVariables = reduce(lazy(elements.values).map { $0.freeVariables }, Set(), +)
		return variables.intersection(replacementVariables)
	}

	public var isIdempotent: Bool {
		return occurringVariables.count == 0
	}


	public func apply(type: Type) -> Type {
		return type.analysis(
			{ self.elements[$0] ?? type },
			{ Type(function: self.apply($0), self.apply($1)) }
		)
	}

	public func apply(scheme: Scheme) -> Scheme {
		return Scheme(scheme.variables, apply(scheme.type))
	}


	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (Variable, Type)...) {
		self.init([:] + elements)
	}


	// MARK: Private

	private let elements: [Variable: Type]
}


public func == (left: Substitution, right: Substitution) -> Bool {
	return left.elements == right.elements
}


internal func + <T: Hashable, U, S: SequenceType where S.Generator.Element == Dictionary<T, U>.Element> (var left: Dictionary<T, U>, right: S) -> Dictionary<T, U> {
	for (key, value) in SequenceOf<(T, U)>(right) {
		if left[key] == nil {
			left[key] = value
		}
	}
	return left
}


// MARK: - Imports

import Set
