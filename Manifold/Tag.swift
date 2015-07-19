//  Copyright © 2015 Rob Rix. All rights reserved.

public typealias Label = String

public typealias Enumeration = List<Label>

public enum Tag {
	case Here(Label, Enumeration)
	case There(Label, Enumeration, () -> Tag)
}
