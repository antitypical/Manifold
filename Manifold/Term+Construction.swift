//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
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

	public static func Lambda(i: Int, _ type: Term?, _ body: Term) -> Term {
		return Term(.Lambda(i, type, body))
	}


	public subscript (operands: Term...) -> Term {
		return operands.reduce(self, combine: Term.Application)
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

public func => (type: Term?, body: Term -> Term) -> Term {
	var n = -1
	let body = body(Term { .Variable(.Local(n)) })
	n = body.maxBoundVariable + 1
	if !body.freeVariables.contains(n) { n = -1 }
	return .Lambda(n, type, body)

}

public func => (left: (Term?, Term?), right: (Term, Term) -> Term) -> Term {
	return left.0 => { a in left.1 => { b in right(a, b) } }
}

public func => (left: (Term?, Term?, Term?), right: (Term, Term, Term) -> Term) -> Term {
	return left.0 => { a in left.1 => { b in left.2 => { c in right(a, b, c) } } }
}


import Prelude