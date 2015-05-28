//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Checkable<Recur> {
	// MARK: Analyses

	public func analysis<T>(
		@noescape #ifType: () -> T,
		@noescape ifBound: Int -> T,
		@noescape ifFree: Name -> T,
		@noescape ifApplication: (Recur, Recur) -> T,
		@noescape ifPi: (Recur, Recur) -> T,
		@noescape ifSigma: (Recur, Recur) -> T) -> T {
		switch self {
		case .Type:
			return ifType()
		case let .Bound(x):
			return ifBound(x)
		case let .Free(x):
			return ifFree(x)
		case let .Application(a, b):
			return ifApplication(a.value, b.value)
		case let .Pi(a, b):
			return ifPi(a.value, b.value)
		case let .Sigma(a, b):
			return ifSigma(a.value, b.value)
		}
	}

	public func analysis<T>(
		ifType: (() -> T)? = nil,
		ifBound: (Int -> T)? = nil,
		ifFree: (Name -> T)? = nil,
		ifApplication: ((Recur, Recur) -> T)? = nil,
		ifPi: ((Recur, Recur) -> T)? = nil,
		ifSigma: ((Recur, Recur) -> T)? = nil,
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

	public func map<T>(@noescape transform: Recur -> T) -> Checkable<T> {
		return analysis(
			ifType: { .Type },
			ifBound: { .Bound($0) },
			ifFree: { .Free($0) },
			ifApplication: { .Application(Box(transform($0)), Box(transform($1))) },
			ifPi: { .Pi(Box(transform($0)), Box(transform($1))) },
			ifSigma: { .Sigma(Box(transform($0)), Box(transform($1))) })
	}


	// MARK: Cases

	case Type
	case Bound(Int)
	case Free(Name)
	case Application(Box<Recur>, Box<Recur>)
	case Pi(Box<Recur>, Box<Recur>) // (Πx:A)B where B can depend on x
	case Sigma(Box<Recur>, Box<Recur>) // (Σx:A)B where B can depend on x
}


import Box
