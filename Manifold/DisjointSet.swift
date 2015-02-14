//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct DisjointSet<T>: ArrayLiteralConvertible {
	public init<S: SequenceType where S.Generator.Element == T>(_ sequence: S) {
		sets = map(enumerate(sequence)) { (parent: $0, rank: 0, value: $1) }
	}


	public mutating func union(a: Int, b: Int) {
		let (r1, r2) = (find(a), find(b))
		let (n1, n2) = (sets[r1], sets[r2])
		if r1 != r2 {
			if n1.rank < n2.rank {
				sets[r1].parent = r2
			} else {
				sets[r2].parent = r1
				if n1.rank == n2.rank {
					++sets[r1].rank
				}
			}
		}
	}

	public mutating func find(a: Int) -> Int {
		let n = sets[a]
		if n.parent == a {
			return a
		} else {
			let parent = find(n.parent)
			sets[a].parent = parent
			return parent
		}
	}


	// MARK: ArrayLiteralConvertible

	public init(arrayLiteral elements: T...) {
		self.init(elements)
	}


	// MARK: Private

	private var sets: [(parent: Int, rank: Int, value: T)]
}
