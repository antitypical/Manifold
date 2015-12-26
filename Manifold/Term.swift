//  Copyright © 2015 Rob Rix. All rights reserved.

public indirect enum Term: Equatable, Hashable, IntegerLiteralConvertible, NilLiteralConvertible, StringLiteralConvertible, TermContainerType {
	case In(Set<Name>, Scoping<Term>)


	public init(_ scoping: Scoping<Term>) {
		switch scoping {
		case let .Variable(name):
			self = .Variable(name)
		case let .Abstraction(name, scope):
			self = .Abstraction(name, scope)
		case let .Identity(body):
			self = Term(body)
		}
	}

	public init(_ expression: Expression<Term>) {
		self = .In(expression.foldMap { $0.freeVariables }, .Identity(expression))
	}


	// MARK: Hashable

	public var hashValue: Int {
		return cata {
			switch $0 {
			case let .Identity(.Type(n)):
				return (Int.max - 59) ^ n
			case let .Variable(n):
				return (Int.max - 83) ^ n.hashValue
			case let .Identity(.Application(a, b)):
				return (Int.max - 95) ^ a ^ b
			case let .Identity(.Lambda(t, b)):
				return (Int.max - 179) ^ t ^ b
			case let .Identity(.Embedded(_, _, type)):
				return (Int.max - 189) ^ type
			case .Identity(.Implicit):
				return (Int.max - 257)
			case let .Abstraction(name, term):
				return (Int.max - 279) ^ name.hashValue ^ term.hashValue
			}
		}
	}


	// MARK: IntegerLiteralConvertible

	public init(integerLiteral value: Int) {
		self = .Variable(.Local(value))
	}


	// MARK: NilLiteralConvertible

	public init(nilLiteral: ()) {
		self.init(.Implicit)
	}


	// MARK: StringLiteralConvertible

	public init(stringLiteral value: String) {
		self = .Variable(.Global(value))
	}


	// MARK: TermContainerType

	public var out: Scoping<Term> {
		switch self {
		case let .In(_, f):
			return f
		}
	}
}


public func == (left: Term, right: Term) -> Bool {
	switch (left, right) {
	case let (.In(v1, f), .In(v2, g)):
		return v1 == v2 && Scoping.equal(==)(f, g)
	}
}
