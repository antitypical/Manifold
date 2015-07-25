//  Copyright © 2015 Rob Rix. All rights reserved.

extension String {
	init<T>( _ value: T, paddedTo max: Int, with padding: Character) {
		let string = String(value)
		self = string + (max > string.characters.count
			? String(count: max - string.characters.count, repeatedValue: padding)
			: "")
	}
}
