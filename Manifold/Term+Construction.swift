//  Copyright © 2015 Rob Rix. All rights reserved.

extension Term {
	public static var Type: Term {
		return Type(0)
	}

	public static func Type(n: Int) -> Term {
		return Term(.Type(n))
	}

	public static func Variable(name: Name) -> Term {
		return .In([ name ], .Variable(name))
	}

	public static func Abstraction(name: Name, _ scope: Term) -> Term {
		return .In(scope.freeVariables.subtract([ name ]), .Abstraction(name, scope))
	}

	public static func Application(a: Term, _ b: Term) -> Term {
		return Term(.Application(a, b))
	}

	public static func Lambda(name: Name, _ type: Term, _ body: Term) -> Term {
		return Term(.Lambda(type, .Abstraction(name, body)))
	}

	public static func Lambda(type: Term, _ body: Term) -> Term {
		return Term(.Lambda(type, body))
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
			guard case let .Identity(.Embedded(value as A, _, _)) = term.out else { throw "Illegal application of '\(name)' : '\(type)' to '\(term)' (expected term of embedded type '\(A.self)')" }
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
	return .Lambda(left, right)
}

public func => (type: Term, body: Term -> Term) -> Term {
	let proposed1 = Name.Local(0)
	let body1 = body(.Variable(proposed1))
	let v1 = body1.freeVariables.union(body1.boundVariables)
	let proposed2 = proposed1.fresh(v1)
	if proposed1 == proposed2 { return .Lambda(type, body1) }

	let body2 = body(.Variable(proposed2))
	let v2 = body2.freeVariables.union(body2.boundVariables)
	
	return v1.subtract([ proposed1 ]) == v2.subtract([ proposed2 ])
		? .Lambda(proposed1, type, body1)
		: .Lambda(proposed2, type, body2)
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
	return .Lambda(left.0, left.1, right)
}

public func => (left: DictionaryLiteral<Name, Term>, right: Term) -> Term {
	return left.reverse().reduce(right) { into, each in
		each => into
	}
}


import Prelude
