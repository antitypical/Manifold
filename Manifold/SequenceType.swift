//  Copyright © 2015 Rob Rix. All rights reserved.

extension SequenceType {
	func fold<Result>(seed: Result, combine: (Generator.Element, () -> Result) -> Result) -> Result {
		var generator = generate()
		func fold() -> Result {
			return generator.next()
				.map {
					combine($0, fold)
				}
				?? seed
		}
		return fold()
	}
}
