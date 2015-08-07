//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Tag: Equatable {
	public static func tags(labels: [String]) -> [Tag] {
		return labels.conses.reduce((there: id, tags: [])) { into, each in
			(there: { Tag.There(each.0, $0) } >>> into.there, tags: into.tags + [ into.there(Tag.Here(each.0, Array(each.1))) ])
		}.tags
	}

	case Here(String, [String])
	indirect case There(String, Tag)
}


import Prelude
