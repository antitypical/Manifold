//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: FixpointType {
	public init(_ type: Constructor<Term>) {
		self.type = type
	}

	public static func out(term: Term) -> Constructor<Term> {
		return term.type
	}

	public let type: Constructor<Term>
}
