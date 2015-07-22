//  Copyright © 2015 Rob Rix. All rights reserved.

extension CollectionType {
	public var uncons: (first: SubSequence._Element, rest: SubSequence)? {
		if !isEmpty {
			let some = self[startIndex..<advance(startIndex, 1)]
			return (first: some[some.startIndex], rest: dropFirst(self))
		}
		return nil
	}

	public var rest: SubSequence {
		return isEmpty
			? self[startIndex..<endIndex]
			: dropFirst(self)
	}
}

extension CollectionType where SubSequence: CollectionType, SubSequence.SubSequence == SubSequence {
	public var conses: AnyGenerator<(first: SubSequence._Element, rest: SubSequence)> {
		var current = uncons
		return anyGenerator {
			let next = current
			current = current?.rest.uncons
			return next
		}
	}
}
