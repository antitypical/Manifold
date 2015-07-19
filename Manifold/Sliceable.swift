//  Copyright © 2015 Rob Rix. All rights reserved.

extension Sliceable {
	public var uncons: (first: SubSlice.Generator.Element, rest: SubSlice)? {
		if !isEmpty {
			let some = self[startIndex..<advance(startIndex, 1)]
			return (first: some[some.startIndex], rest: dropFirst(self))
		}
		return nil
	}

	public var rest: SubSlice {
		return isEmpty
			? self[startIndex..<endIndex]
			: dropFirst(self)
	}
}

extension Sliceable where SubSlice == Self {
	public var conses: AnyGenerator<(first: SubSlice.Generator.Element, rest: SubSlice)> {
		var current = uncons
		return anyGenerator {
			let next = current
			current = current?.rest.uncons
			return next
		}
	}
}
