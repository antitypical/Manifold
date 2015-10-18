//  Copyright © 2015 Rob Rix. All rights reserved.

extension CollectionType where SubSequence == Self {
	public func fold<Out>(initial: Out, @noescape combine: (Generator.Element, Out) -> Out) -> Out {
		return first.map {
			combine($0, dropFirst().fold(initial, combine: combine))
		} ?? initial
	}
}
