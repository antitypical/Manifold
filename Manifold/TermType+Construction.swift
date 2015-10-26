//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	// MARK: First-order construction

	public static var Type: Self {
		return Type(0)
	}

	public static func Type(n: Int) -> Self {
		return Self(.Type(n))
	}

	public static func Variable(name: Name) -> Self {
		return Self(.Variable(name))
	}

	public static func Application(a: Self, _ b: Self) -> Self {
		return Self(.Application(a, b))
	}

	public static func Lambda(i: Int, _ type: Self, _ body: Self) -> Self {
		return Self(.Lambda(i, type, body))
	}


	public subscript (operands: Self...) -> Self {
		return operands.reduce(self, combine: Self.Application)
	}


	// MARK: Higher-order construction

	public static func lambda(type: Self, _ body: Self -> Self) -> Self {
		var n = -1
		let body = body(Self { .Variable(.Local(n)) })
		n = body.maxBoundVariable + 1
		if !body.freeVariables.contains(n) { n = -1 }
		return .Lambda(n, type, body)
	}

	public static func lambda(type1: Self, _ type2: Self, _ body: (Self, Self) -> Self) -> Self {
		return lambda(type1) { a in lambda(type2) { b in body(a, b) } }
	}

	public static func lambda(type1: Self, _ type2: Self, _ type3: Self, _ body: (Self, Self, Self) -> Self) -> Self {
		return lambda(type1) { a in lambda(type2) { b in lambda(type3) { c in body(a, b, c) } } }
	}


	public init<T: TermContainerType>(term: T) {
		self.init(expression: term.out)
	}

	public init<T: TermContainerType>(expression: Expression<T>) {
		self.init(expression.map { Self(term: $0) })
	}


	public init(integerLiteral value: Int) {
		self.init(.Variable(.Local(value)))
	}


	public init(stringLiteral value: String) {
		self.init(.Variable(.Global(value)))
	}

	public init(unicodeScalarLiteral: Self.StringLiteralType) {
		self.init(stringLiteral: unicodeScalarLiteral)
	}

	public init(extendedGraphemeClusterLiteral: Self.StringLiteralType) {
		self.init(stringLiteral: extendedGraphemeClusterLiteral)
	}
}


infix operator --> {
	associativity right
	precedence 120
}

infix operator => {
	associativity right
	precedence 120
}

public func --> <Term: TermType> (left: Term, right: Term) -> Term {
	return .lambda(left, const(right))
}

public func => <Term: TermType> (left: Term, right: Term -> Term) -> Term {
	return .lambda(left, right)
}

public func => <Term: TermType> (left: (Term, Term), right: (Term, Term) -> Term) -> Term {
	return .lambda(left.0, left.1, right)
}

public func => <Term: TermType> (left: (Term, Term, Term), right: (Term, Term, Term) -> Term) -> Term {
	return .lambda(left.0, left.1, left.2, right)
}


import Prelude
