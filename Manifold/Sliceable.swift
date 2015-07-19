//  Copyright © 2015 Rob Rix. All rights reserved.

extension Sliceable {
	public var rest: SubSlice {
		return isEmpty
			? self[startIndex..<endIndex]
			: dropFirst(self)
	}
}
