//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public static var Type: Term {
		return Type(0)
	}

	public static func Type(n: Int) -> Term {
		return Term(.Type(n))
	}

	public static func Variable(name: Name) -> Term {
		return Term([ name ], .Variable(name))
	}

	public static func Application(a: Term, _ b: Term) -> Term {
		return Term(.Application(a, b))
	}

	public static func Lambda(i: Int, _ type: Term, _ body: Term) -> Term {
		return Term(body.freeVariables.subtract([ .Local(i) ]), .Lambda(i, type, body))
	}

	public static func Embedded(name: String, _ type: Term, _ evaluator: Term throws -> Term) -> Term {
		let equal: (Any, Any) -> Bool = { a, b in
			guard let a = a as? (String, Term throws -> Term), b = b as? (String, Term throws -> Term) else { return false }
			return a.0 == b.0
		}
		return Term(.Embedded((name, evaluator), equal, type))
	}

	public static func Embedded<A>(name: String, _ type: Term, _ evaluator: A throws -> Term) -> Term {
		return Embedded(name, type) { term in
			guard case let .Embedded(value as A, _, _) = term.out else { throw "Illegal application of '\(name)' to '\(term)'" }
			return try evaluator(value)
		}
	}

	public static func Embedded<A>(value: A, _ equal: (A, A) -> Bool, _ type: Term) -> Term {
		let equal: (Any, Any) -> Bool = { a, b in
			guard let a = a as? A, b = b as? A else { return false }
			return equal(a, b)
		}
		return Term(.Embedded(value as Any, equal, type))
	}

	public static func Embedded<A: Equatable>(value: A, _ type: Term) -> Term {
		return .Embedded(value, ==, type)
	}

	public static func Embedded<A: Equatable>(value: A) -> Term {
		return .Embedded(value, .Embedded(A.self))
	}

	public static func Embedded<A: Equatable>(type: A.Type) -> Term {
		return .Embedded(A.self, (==) as (A.Type, A.Type) -> Bool, .Type)
	}

	public static var Implicit: Term {
		return nil
	}


	public subscript (operands: Term...) -> Term {
		return operands.reduce(self, combine: Term.Application)
	}


	public init<T: TermContainerType>(term: T) {
		self.init(term.out.map { Term(term: $0) })
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

public func => (type: Term, body: Term -> Term) -> Term {
	var n = -1
	let body = body(Term { .Variable(.Local(n)) })
	n = body.maxBoundVariable + 1
	if !body.freeVariables.contains(n) { n = -1 }
	return .Lambda(n, type, body)
}

public func => (left: (Term, Term), right: (Term, Term) -> Term) -> Term {
	return left.0 => { a in left.1 => { b in right(a, b) } }
}

public func => (left: (Term, Term, Term), right: (Term, Term, Term) -> Term) -> Term {
	return left.0 => { a in left.1 => { b in left.2 => { c in right(a, b, c) } } }
}

public func => (left: (Term, Term, Term, Term), right: (Term, Term, Term, Term) -> Term) -> Term {
	return left.0 => { a in left.1 => { b in left.2 => { c in left.3 => { d in right(a, b, c, d) } } } }
}

public func => (left: (Name, Term), right: Term) -> Term {
	return .Lambda(-1, left.1, right)
}

public func => (left: DictionaryLiteral<Name, Term>, right: Term) -> Term {
	return left.reverse().reduce(right) { into, each in
		each => into
	}
}


import Prelude
