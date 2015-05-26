//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Neutral: DebugPrintable {
	// MARK: Quotation

	func quote(n: Int) -> Term {
		return analysis(
			ifParameter: {
				$0.analysis(
					ifGlobal: const(Term.free($0)),
					ifLocal: const(Term.free($0)),
					ifQuote: Term.bound)
			},
			ifApplication: { Term.application($0.quote(n), $1.quote(n)) })
	}


	// MARK: Analyses

	func analysis<T>(@noescape #ifParameter: Name -> T, @noescape ifApplication: (Neutral, Value) -> T) -> T {
		switch self {
		case let .Parameter(n):
			return ifParameter(n)
		case let .Application(n, v):
			return ifApplication(n.value, v)
		}
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return analysis(
			ifParameter: toDebugString,
			ifApplication: { "\(toDebugString($0))(\(toDebugString($1)))" })
	}


	// MARK: Cases

	case Parameter(Name)
	case Application(Box<Neutral>, Value)
}


import Box
import Prelude
