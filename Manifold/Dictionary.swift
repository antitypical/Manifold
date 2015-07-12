//  Copyright © 2015 Rob Rix. All rights reserved.

extension Dictionary {
	internal init<S: SequenceType where S.Generator.Element == Element>(_ elements: S) {
		self.init()
		for (key, value) in elements {
			self[key] = value
		}
	}
}

internal func + <T: Hashable, U, S: SequenceType where S.Generator.Element == Dictionary<T, U>.Element> (var left: Dictionary<T, U>, right: S) -> Dictionary<T, U> {
	for (key, value) in AnySequence<(T, U)>(right) {
		if left[key] == nil {
			left[key] = value
		}
	}
	return left
}
