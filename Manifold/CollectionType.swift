//  Copyright © 2015 Rob Rix. All rights reserved.

extension CollectionType {
	public var uncons: (first: SubSequence._Element, rest: SubSequence)? {
		if !isEmpty {
			let some = self[startIndex..<startIndex.advancedBy(1)]
			return (first: some[some.startIndex], rest: dropFirst())
		}
		return nil
	}

	public var rest: SubSequence {
		return isEmpty
			? self[startIndex..<endIndex]
			: dropFirst()
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


extension CollectionType where SubSequence == Self {
	func fold<Out>(initial: Out, @noescape combine: (Generator.Element, Out) -> Out) -> Out {
		return first.map {
			combine($0, dropFirst().fold(initial, combine: combine))
		} ?? initial
	}
}
