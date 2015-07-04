//  Copyright © 2015 Rob Rix. All rights reserved.

final class ScanSequenceViewTests: XCTestCase {
	func testSequenceTypeScanEvaluatesEagerly() {
		var i = 0
		[1, 2, 3, 4, 5, 6].scan(0) { i += $0 + $1 ; return i }
		assert(i, ==, 120)
	}

	func testLazySequenceScanEvaluatesLazily() {
		var i = 0
		lazy([1, 2, 3, 4, 5, 6]).scan(0) { i += $0 + $1 ; return i }
		assert(i, ==, 0)
	}

	func testScanOfEmptySequenceProducesInitialValue() {
		assert([Int]().scan(0, combine: +), ==, [0])
	}

	func testProducesAValueForEachIteration() {
		assert([ 0, 1, 2 ].scan(0, combine: +), ==, [ 0, 0, 1, 3 ])
	}
}


import Assertions
@testable import Manifold
import XCTest
