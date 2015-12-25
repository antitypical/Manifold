//  Copyright © 2015 Rob Rix. All rights reserved.

protocol MonoidType {
	static var mempty: Self { get }
	func mappend(other: Self) -> Self
}
