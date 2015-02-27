//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Substitution: DictionaryLiteralConvertible, Equatable, Printable {
	public init<S: SequenceType where S.Generator.Element == Dictionary<Variable, Type>.Element>(_ sequence: S) {
		self.elements = [:] + sequence
	}


	public func compose(other: Substitution) -> Substitution {
		return Substitution(other.elements + elements)
	}

	public var variables: Set<Variable> {
		return Set(elements.keys)
	}

	public var occurringVariables: Set<Variable> {
		let replacementVariables = reduce(lazy(elements.values).map { $0.freeVariables }, Set(), uncurry(Set.union))
		return variables.intersect(replacementVariables)
	}

	public var isIdempotent: Bool {
		return occurringVariables.count == 0
	}


	public func apply(type: Type) -> Type {
		return type.analysis(
			ifVariable: { self.elements[$0] ?? type },
			ifConstructed: {
				$0.analysis(
					ifUnit: type,
					ifBool: type,
					ifFunction: { Type(function: self.apply($0), self.apply($1)) })
			},
			ifUniversal: { Type(forall: $0, self.apply($1)) })
	}


	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (Variable, Type)...) {
		self.init(elements)
	}


	// MARK: Printable

	public var description: String {
		return "[" + ", ".join(lazy(elements).map { "\(Type($0)) := \($1)" }) + "]"
	}


	// MARK: Private

	private let elements: [Variable: Type]
}


public func == <T: Equatable, U: Equatable> (left: [(T, U)], right: [(T, U)]) -> Bool {
	return left.count == right.count && reduce(lazy(zip(left, right)).map(==), true) { $0 && $1 }
}

public func == (left: Substitution, right: Substitution) -> Bool {
	return left.elements == right.elements
}

public func find<C: CollectionType>(collection: C, predicate: C.Generator.Element -> Bool) -> C.Index? {
	for (index, each) in zip(indices(collection), collection) {
		if predicate(each) { return index }
	}
	return nil
}


// MARK: - Imports

import Prelude
