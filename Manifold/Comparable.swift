//  Copyright (c) 2015 Rob Rix. All rights reserved.

// MARK: Term.Sort

public func < (left: Term.Sort, right: Term.Sort) -> Bool {
	switch (left, right) {
	case (.Term, .Type), (.Type, .Kind):
		return true
	default:
		return false
	}
}
