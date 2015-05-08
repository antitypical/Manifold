//  Copyright (c) 2015 Rob Rix. All rights reserved.

// MARK: DTerm.Sort

public func < (left: DTerm.Sort, right: DTerm.Sort) -> Bool {
	switch (left, right) {
	case (.Term, .Type), (.Type, .Kind):
		return true
	default:
		return false
	}
}
