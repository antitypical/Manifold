//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Term: Equatable, Hashable, IntegerLiteralConvertible, NilLiteralConvertible, StringLiteralConvertible, TermContainerType {
	case In(Set<Name>, () -> Expression<Term>)


	public init(_ expression: () -> Expression<Term>) {
		self = .In([], expression)
	}

	public init(_ expression: Expression<Term>) {
		self.init { expression }
	}

	public init(_ freeVariables: Set<Name>, _ expression: Expression<Term>) {
		self = Term.In(freeVariables) { expression }
	}


	// MARK: Hashable

	public var hashValue: Int {
		return cata {
			switch $0 {
			case let .Type(n):
				return (Int.max - 59) ^ n
			case let .Variable(n):
				return (Int.max - 83) ^ n.hashValue
			case let .Application(a, b):
				return (Int.max - 95) ^ a ^ b
			case let .Lambda(i, t, b):
				return (Int.max - 179) ^ i ^ t ^ b
			case let .Embedded(_, _, type):
				return (Int.max - 189) ^ type
			case .Implicit:
				return (Int.max - 257)
			}
		}
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: Int) {
		self.init(.Variable(.Local(value)))
	}


	// MARK: NilLiteralConvertible

	public init(nilLiteral: ()) {
		self.init(.Implicit)
	}


	// MARK: StringLiteralConvertible

	public init(stringLiteral value: String) {
		self.init(.Variable(.Global(value)))
	}


	// MARK: TermContainerType

	public var out: Expression<Term> {
		switch self {
		case let .In(_, f):
			return f()
		}
	}

	var scoping: Scoping<Expression<Term>, Term> {
		switch out {
		case let .Variable(name):
			return .Variable(name)
		case let .Lambda(i, _, body):
			return .Abstraction(.Local(i), body)
		default:
			return .Identity(out)
		}
	}
}


public func == (left: Term, right: Term) -> Bool {
	switch (left, right) {
	case let (.In(v1, f), .In(v2, g)):
		return v1 == v2 && f() == g()
	}
}
