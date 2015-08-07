//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Tag<Term : TermType> {
	case Here(String, [String])
	indirect case There(String, Tag)
}
