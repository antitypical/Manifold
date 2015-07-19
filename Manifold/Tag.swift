//  Copyright © 2015 Rob Rix. All rights reserved.

public typealias Label = String

public typealias Enumeration = [Label]

public enum Tag: Equatable, CustomDebugStringConvertible, CustomStringConvertible {
	case Here(Label, Enumeration)
	case There(Label, Enumeration, () -> Tag)

	public static func tags(enumeration: Enumeration) -> [Tag] {
		struct State {
			let tags: [Tag]
			let there: (Label, Enumeration) -> Tag
		}
		return enumeration[enumeration.indices].conses.reduce(State(tags: [], there: Tag.Here)) { into, each in
			State(tags: into.tags + [ into.there(each.first, Array(each.rest)) ], there: { l, e in Tag.There(each.first, Array(each.rest), { into.there(l, e) }) })
		}.tags
	}

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


	public var debugDescription: String {
		switch self {
		case let .Here(label, rest):
			let s = " :: ".join(rest + [ "[]" ])
			return "(\(label)) :: \(s)"
		case let .There(label, _, next):
			return "\(label) :: \(String(reflecting: next()))"
		}
	}

	public var description: String {
		return label
	}
}
