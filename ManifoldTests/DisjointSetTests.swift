//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class DisjointSetTests: XCTestCase {
	func testEveryElementIsInitiallyDisjoint() {
		var set: DisjointSet<String> = [ "a", "b", "c", "d", "e" ]
		if !reduce(lazy(enumerate(set))
			.map { index, _ in (index, set.find(index)) }
			.map(==), true, { $0 && $1 }) {
			failure("it didn't work")
		}
	}

	func testUnionCombinesPartitions() {
		var set: DisjointSet<String> = [ "a", "b", "c", "d", "e" ]
		set.union(1, 3)
		assertEqual(set.findAll().count, 4)
	}
}


// MARK: - Imports

import Manifold
import XCTest
