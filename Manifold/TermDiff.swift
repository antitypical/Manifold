//  Copyright © 2015 Rob Rix. All rights reserved.

public enum TermDiff {
	case Patch(Term, Term)
	indirect case Roll(Expression<TermDiff>)

	public init(_ term: Term) {
		self = .Roll(term.out.map(TermDiff.init))
	}

	public init(_ left: Term, _ right: Term, _ environment: [Name:Term]) {
		var visited: Set<Term> = []
		func unify(left: Term, _ right: Term) -> (TermDiff, Set<Term>) {
			let (leftʹ, visitedLeft) = left.weakHeadNormalForm(environment, shouldRecur: true, visited: visited)
			let (rightʹ, visitedRight) = right.weakHeadNormalForm(environment, shouldRecur: true, visited: visited)
			visited.unionInPlace(visitedLeft)
			visited.unionInPlace(visitedRight)

			if leftʹ == rightʹ { return (TermDiff(rightʹ), visited) }

			switch (leftʹ.out, rightʹ.out) {
			case (.Implicit, _):
				return (TermDiff(rightʹ), visited)
			case (_, .Implicit):
				return (TermDiff(leftʹ), visited)

			case (.Type, .Type):
				return (TermDiff(rightʹ), visited)

			case let (.Application(a1, b1), .Application(a2, b2)):
				let (a, visitedA) = unify(a1, a2)
				let (b, visitedB) = unify(b1, b2)
				visited.unionInPlace(visitedA)
				visited.unionInPlace(visitedB)
				return (.Roll(.Application(a, b)), visited)

			case let (.Lambda(_, type1, body1), .Lambda(i, type2, body2)):
				let (type, visitedType) = unify(type1, type2)
				let (body, visitedBody) = unify(body1, body2)
				visited.unionInPlace(visitedType)
				visited.unionInPlace(visitedBody)
				return (.Roll(.Lambda(i, type, body)), visited)

			default:
				return (.Patch(leftʹ, rightʹ), visited)
			}
		}
		(self, _) = unify(left, right)
	}


	/// Produces the unified term for the receiver, if any.
	///
	/// This will be a valid term for unifiable terms, and `nil` otherwise.
	public var unified: Term? {
		struct E: ErrorType {}
		func unified(diff: TermDiff) throws -> Term {
			switch diff {
			case .Patch:
				throw E()

			case let .Roll(expression):
				return try Term(expression.map(unified))
			}
		}
		return try? unified(self)
	}
}
