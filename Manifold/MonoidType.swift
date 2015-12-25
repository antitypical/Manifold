//  Copyright © 2015 Rob Rix. All rights reserved.

protocol MonoidType {
	static var mempty: Self { get }
	func mappend(other: Self) -> Self
}


extension Set: MonoidType {
	static var mempty: Set {
		return []
	}

	func mappend(other: Set) -> Set {
		return union(other)
	}
}
