//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Substitution: DictionaryLiteralConvertible, Equatable, Printable {
	public init<S: SequenceType where S.Generator.Element == (Variable, Term)>(_ sequence: S) {
		self.elements = [:] + sequence
	}


	public func compose(other: Substitution) -> Substitution {
		let variables = self.variables
		return Substitution(map(elements) { ($0, other.apply($1)) } + lazy(other.elements).filter { !variables.contains($0.0) })
	}

	public var variables: Set<Variable> {
		return Set(elements.keys)
	}

	public var occurringVariables: Set<Variable> {
		let replacementVariables = reduce(lazy(elements).map { $1.freeVariables }, Set(), uncurry(Set.union))
		return variables.intersect(replacementVariables)
	}

	public var isIdempotent: Bool {
		return occurringVariables.count == 0
	}


	public func apply(term: Term) -> Term {
		return term.type.analysis(
			ifVariable: { self.elements[$0] ?? term },
			ifConstructed: {
				$0.analysis(
					ifUnit: term,
					ifFunction: { Term(function: self.apply($0), self.apply($1)) },
					ifSum: { Term(sum: self.apply($0), self.apply($1)) },
					ifProduct: { Term(product: self.apply($0), self.apply($1)) })
			},
			ifUniversal: { Term(forall: $0, self.apply($1)) })
	}


	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (Variable, Term)...) {
		self.init(elements)
	}


	// MARK: Printable

	public var description: String {
		return "[" + ", ".join(lazy(elements).map { "\(Term($0)) := \($1)" }) + "]"
	}


	// MARK: Private

	private let elements: [Variable: Term]
}


public func == (left: Substitution, right: Substitution) -> Bool {
	return left.elements == right.elements
}


// MARK: - Imports

import Prelude
