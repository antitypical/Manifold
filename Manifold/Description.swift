//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Description<Term: TermType>: DictionaryLiteralConvertible {
	public init(dictionaryLiteral elements: (String, Description<Term>)...) {
		switch elements.count {
		case 0:
			self = .End
		case 1:
			self = elements[0].1
		case let x:
			self = .Argument(Term(.Axiom(x, Term(.Axiom(Int.self, Term(.Type(0)))))), { tag in
				// at this point we have a variable standing in for the tag
				if case let .Axiom(any, _) = tag.out, let i = any as? Int {
					return elements[i].1
				}
				fatalError("tag \(tag) was not embedded Int")
			})
		}
	}

	case End
	indirect case Recursive(Description)
	indirect case Argument(Term, Term -> Description)

	func term(name: String) -> Term {
		switch self {
		case .End:
			return Term(.UnitType)
		case let .Recursive(rest):
			return Term(.Product(Term(.Variable(Name.Global(name))), rest.term(name)))
		case let .Argument(argument, continuation):
			return Term(.Product(argument, Term(Expression.lambda(argument) { continuation($0).term(name) })))
		}
	}
}


import Prelude
