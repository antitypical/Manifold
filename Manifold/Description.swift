//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType {
	public static var description: Module<Recur> {
		let Tag: Recur -> Recur = { Recur("Tag")[$0] }
		let Description = Recur("Description")
		let cons: (Recur, Recur) -> Recur = { Recur("::")[$0, $1] }
		let `nil` = Recur("[]")

		let label: String -> Recur = {
			.Axiom($0, Recur("String"))
		}

		let list: [Recur] -> Recur = fix { list in
			{ $0.uncons.map { cons($0, list(Array($1))) } ?? `nil` }
		}

		let here: (Recur, Recur) -> Recur = {
			Recur("here")[$0, $1]
		}

		let endTag = here(label("End"), list(["Recur", "Argument"].map(label)))

		// End : λ I : Type . λ _ : I . Description I
		// End = λ I : Type . λ i : I . (:End, i) : Description I
		let end = Declaration("End",
			type: lambda(.Type) { I in Recur.lambda(I, const(Description[I])) },
			value: lambda(.Type) { I in Recur.lambda(I) { i in .Annotation(.Product(endTag, i), Description[I]) } })

		return Module([ Expression.list, tag ], [
			end,
		])
	}
}

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
