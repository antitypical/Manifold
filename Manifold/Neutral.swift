//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Neutral: DebugPrintable {
	// MARK: Constructors

	public static func application(f: Neutral, _ v: Value) -> Neutral {
		return .Application(Box(f), v)
	}


	// MARK: Quotation

	public func quote(n: Int) -> Term {
		return analysis(
			ifFree: {
				$0.analysis(
					ifGlobal: const(Term.free($0)),
					ifLocal: const(Term.free($0)),
					ifQuote: Term.bound)
			},
			ifApplication: { Term.application($0.quote(n), $1.quote(n)) })
	}


	// MARK: Analyses

	public func analysis<T>(@noescape #ifFree: Name -> T, @noescape ifApplication: (Neutral, Value) -> T) -> T {
		switch self {
		case let .Free(n):
			return ifFree(n)
		case let .Application(n, v):
			return ifApplication(n.value, v)
		}
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return analysis(
			ifFree: toDebugString,
			ifApplication: { "\(toDebugString($0))(\(toDebugString($1)))" })
	}


	// MARK: Cases

	case Free(Name)
	case Application(Box<Neutral>, Value)
}


import Box
import Prelude
