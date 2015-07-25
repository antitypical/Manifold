//  Copyright © 2015 Rob Rix. All rights reserved.

// MARK: Name

public func < (left: Name, right: Name) -> Bool {
	switch (left, right) {
	case let (.Local(a), .Local(b)):
		return a < b
	case let (.Global(a), .Global(b)):
		return a < b
	case (.Local, .Global):
		return true
	case (.Global, .Local):
		return false
	}
}
