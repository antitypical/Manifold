//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	// MARK: First-order construction

	public static var Type: Term {
		return Type(0)
	}

	public static func Type(n: Int) -> Term {
		return Term(.Type(n))
	}

	public static func Variable(name: Name) -> Term {
		return Term(.Variable(name))
	}

	public static func Application(a: Term, _ b: Term) -> Term {
		return Term(.Application(a, b))
	}

	public static func Lambda(i: Int, _ type: Term, _ body: Term) -> Term {
		return Term(.Lambda(i, type, body))
	}


	public subscript (operands: Term...) -> Term {
		return operands.reduce(self, combine: Term.Application)
	}


	// MARK: Higher-order construction

	public static func lambda(type: Term, _ body: Term -> Term) -> Term {
		var n = -1
		let body = body(Term { .Variable(.Local(n)) })
		n = body.maxBoundVariable + 1
		if !body.freeVariables.contains(n) { n = -1 }
		return .Lambda(n, type, body)
	}

	public static func lambda(type1: Term, _ type2: Term, _ body: (Term, Term) -> Term) -> Term {
		return lambda(type1) { a in lambda(type2) { b in body(a, b) } }
	}

	public static func lambda(type1: Term, _ type2: Term, _ type3: Term, _ body: (Term, Term, Term) -> Term) -> Term {
		return lambda(type1) { a in lambda(type2) { b in lambda(type3) { c in body(a, b, c) } } }
	}


	public init<T: TermContainerType>(term: T) {
		self.init(term.out.map { Term(term: $0) })
	}


	public init(integerLiteral value: Int) {
		self.init(.Variable(.Local(value)))
	}


	public init(stringLiteral value: String) {
		self.init(.Variable(.Global(value)))
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

public func --> (left: Term, right: Term) -> Term {
	return left => const(right)
}

public func => (left: Term, right: Term -> Term) -> Term {
	return .lambda(left, right)
}

public func => (left: (Term, Term), right: (Term, Term) -> Term) -> Term {
	return .lambda(left.0, left.1, right)
}

public func => (left: (Term, Term, Term), right: (Term, Term, Term) -> Term) -> Term {
	return .lambda(left.0, left.1, left.2, right)
}


import Prelude
