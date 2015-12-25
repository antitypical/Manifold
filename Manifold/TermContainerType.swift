//  Copyright © 2015 Rob Rix. All rights reserved.

public protocol TermContainerType: CustomStringConvertible {
	var out: Expression<Self> { get }

	var freeVariables: Set<Name> { get }
}

extension TermContainerType {
	public static func out(container: Self) -> Expression<Self> {
		return container.out
	}

	public func cata<Result>(transform: Expression<Result> -> Result) -> Result {
		return (Self.out >>> { $0.map { $0.cata(transform) } } >>> transform)(self)
	}

	public func para<Result>(transform: Expression<(Self, Result)> -> Result) -> Result {
		return (Self.out >>> { $0.map { ($0, $0.para(transform)) } } >>> transform)(self)
	}
}


import Prelude
