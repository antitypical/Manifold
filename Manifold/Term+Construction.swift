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

	public static func Abstraction(name: Name, _ scope: Term) -> Term {
		return Term(scope.freeVariables.subtract([ name ]), .Abstraction(name, scope))
	}

	public static func Application(a: Term, _ b: Term) -> Term {
		return Term(.Application(a, b))
	}

	public static func Lambda(name: Name, _ type: Term, _ body: Term) -> Term {
		return Term(body.freeVariables.subtract([ name ]), .Identity(.Lambda(type, body)))
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
			guard case let .Identity(.Embedded(value as A, _, _)) = term.out else { throw "Illegal application of '\(name)' to '\(term)'" }
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
	return .Lambda(type, body(.Variable(.Local(-1))))
}

public func => (left: (Term, Term), right: (Term, Term) -> Term) -> Term {
	return [Name.Local(-1): left.0, Name.Local(-1): left.1] => right(-1, -1)
}

public func => (left: (Term, Term, Term), right: (Term, Term, Term) -> Term) -> Term {
	return [Name.Local(-1): left.0, Name.Local(-1): left.1, Name.Local(-1): left.2] => right(-1, -1, -1)
}

public func => (left: (Term, Term, Term, Term), right: (Term, Term, Term, Term) -> Term) -> Term {
	return [Name.Local(-1): left.0, Name.Local(-1): left.1, Name.Local(-1): left.2, Name.Local(-1): left.3] => right(-1, -1, -1, -1)
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
