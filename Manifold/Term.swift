//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: FixpointType, Hashable {
	public init(_ type: Constructor<Term>) {
		self.type = type
	}

	public static func out(term: Term) -> Constructor<Term> {
		return term.type
	}

	public let type: Constructor<Term>


	public var distinctTerms: Set<Term> {
		return type.reduce([], { $0.union([ $1 ]) })
	}


	// MARK: Hashable

	public var hashValue: Int {
		return type.analysis(
			ifUnit: 1,
			ifFunction: hash(2),
			ifSum: hash(3))
	}
}


public func == (left: Term, right: Term) -> Bool {
	return left.type == right.type
}


// MARK: - Implementation details

private func hash<A: Hashable, B: Hashable>(n: Int)(a: A, b: B) -> Int {
	return n ^ a.hashValue ^ b.hashValue
}
