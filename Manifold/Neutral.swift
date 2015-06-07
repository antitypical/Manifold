//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Neutral: DebugPrintable {
	// MARK: Constructors

	public static func application(f: Neutral, _ v: Value) -> Neutral {
		return .Application(Box(f), v)
	}

	public static func projection(a: Neutral, _ b: Bool) -> Neutral {
		return .Projection(Box(a), b)
	}


	// MARK: Quotation

	public func quote(n: Int) -> Term {
		return analysis(
			ifFree: {
				$0.analysis(
					ifGlobal: const(Term.free($0)),
					ifLocal: const(Term.free($0)),
					ifQuote: { Term.bound(n - $0 - 1) })
			},
			ifApplication: { Term.application($0.quote(n), $1.quote(n)) },
			ifProjection: { Term.projection($0.quote(n), $1) })
	}


	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifFree: Name -> T,
		@noescape ifApplication: (Neutral, Value) -> T,
		@noescape ifProjection: (Neutral, Bool) -> T) -> T {
		switch self {
		case let .Free(n):
			return ifFree(n)
		case let .Application(n, v):
			return ifApplication(n.value, v)
		case let .Projection(n, v):
			return ifProjection(n.value, v)
		}
	}


	// MARK: DebugPrintable

	public var debugDescription: String {
		return analysis(
			ifFree: toDebugString,
			ifApplication: { "\(toDebugString($0))(\(toDebugString($1)))" },
			ifProjection: { "\(toDebugString($0)).\($1 ? 1 : 0)" })
	}


	// MARK: Cases

	case Free(Name)
	case Application(Box<Neutral>, Value)
	case Projection(Box<Neutral>, Bool)
}


import Box
import Prelude
