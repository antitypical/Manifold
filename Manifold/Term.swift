//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Term: FixpointType, Hashable {
	public let type: Type


	public var freeVariables: Set<Variable> {
		return []
	}

	public var distinctTerms: Set<Type> {
		return type.reduce([], { $0.union([ $1 ]) })
	}


	// MARK: Hashable

	public var hashValue: Int {
		return type.analysis(
			ifVariable: { $0.hashValue },
			ifConstructed: {
				$0.analysis(
					ifUnit: 1,
					ifFunction: hash(2),
					ifSum: hash(3))
			},
			ifUniversal: hash(4))
	}


	// MARK: FixpointType

	public init(_ type: Type) {
		self.type = type
	}

	public static func out(term: Term) -> Type {
		return term.type
	}
}


public func == (left: Term, right: Term) -> Bool {
	return left.type == right.type
}


// MARK: - Implementation details

private func hash<A: Hashable, B: Hashable>(n: Int)(a: A, b: B) -> Int {
	return n ^ a.hashValue ^ b.hashValue
}
