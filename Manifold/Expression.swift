//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Expression<Recur> {
	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifType: () -> T,
		@noescape ifBound: Int -> T,
		@noescape ifFree: Name -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifPi: (Int, Recur, Recur) -> T,
		@noescape ifSigma: (Int, Recur, Recur) -> T) -> T {
		switch self {
		case .Type:
			return ifType()
		case let .Bound(x):
			return ifBound(x)
		case let .Free(x):
			return ifFree(x)
		case let .Application(a, b):
			return ifApplication(a.value, b.value)
		case let .Pi(i, a, b):
			return ifPi(i, a.value, b.value)
		case let .Sigma(i, a, b):
			return ifSigma(i, a.value, b.value)
		}
	}

	public func analysis<T>(
		ifType: (() -> T)? = nil,
		ifBound: (Int -> T)? = nil,
		ifFree: (Name -> T)? = nil,
		ifApplication: ((Recur, Recur) -> T)? = nil,
		ifPi: ((Int, Recur, Recur) -> T)? = nil,
		ifSigma: ((Int, Recur, Recur) -> T)? = nil,
		@noescape otherwise: () -> T) -> T {
		return analysis(
			ifType: { ifType?() ?? otherwise() },
			ifBound: { ifBound?($0) ?? otherwise() },
			ifFree: { ifFree?($0) ?? otherwise() },
			ifApplication: { ifApplication?($0) ?? otherwise() },
			ifPi: { ifPi?($0) ?? otherwise() },
			ifSigma: { ifSigma?($0) ?? otherwise() })
	}


	// MARK: Functor

	public func map<T>(@noescape transform: Recur -> T) -> Expression<T> {
		return analysis(
			ifType: { .Type },
			ifBound: { .Bound($0) },
			ifFree: { .Free($0) },
			ifApplication: { .Application(Box(transform($0)), Box(transform($1))) },
			ifPi: { .Pi($0, Box(transform($1)), Box(transform($2))) },
			ifSigma: { .Sigma($0, Box(transform($1)), Box(transform($2))) })
	}


	// MARK: Cases

	case Type
	case Bound(Int)
	case Free(Name)
	case Application(Box<Recur>, Box<Recur>)
	case Pi(Int, Box<Recur>, Box<Recur>) // (Πx:A)B where B can depend on x
	case Sigma(Int, Box<Recur>, Box<Recur>) // (Σx:A)B where B can depend on x
}


import Box
