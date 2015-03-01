//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: FixpointType {
	public init(_ out: Constructor<Term>) {
		self.out = out
	}

	public static func out(term: Term) -> Constructor<Term> {
		return term.out
	}

	public let out: Constructor<Term>
}
