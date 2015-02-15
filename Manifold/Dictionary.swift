//  Copyright (c) 2015 Rob Rix. All rights reserved.

extension Dictionary {
	init<S: SequenceType where S.Generator.Element == Element>(_ elements: S) {
		self.init()
		for (key, value) in elements {
			self[key] = value
		}
	}
}
