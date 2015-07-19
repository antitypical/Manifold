//  Copyright © 2015 Rob Rix. All rights reserved.

public typealias Label = String

public typealias Enumeration = List<Label>

public enum Tag {
	case Here(Label, Enumeration)
	case There(Label, Enumeration, () -> Tag)

	public var label: Label {
		switch self {
		case let .Here(l, _):
			return l
		case let .There(l, _, _):
			return l
		}
	}

	public var enumeration: Enumeration {
		switch self {
		case let .Here(_, e):
			return e
		case let .There(_, e, _):
			return e
		}
	}
}
