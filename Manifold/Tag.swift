//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Tag: Equatable {
	public static func tags(labels: [String]) -> [Tag] {
		return labels.conses.reduce((there: id, tags: [])) { into, each in
			(there: { Tag.There(each.0, $0) } >>> into.there, tags: into.tags + [ into.there(Tag.Here(each.0, Array(each.1))) ])
		}.tags
	}

	var cases: [String] {
		switch self {
		case let .Here(s, ss):
			return [s] + ss
		case let .There(s, t):
			return [s] + t.cases
		}
	}

	static func encodeTagType<Term: TermType>(labels: [String]) -> Term {
		return .UnitType
	}

	case Here(String, [String])
	indirect case There(String, Tag)
}


import Prelude
