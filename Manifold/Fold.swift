//  Copyright © 2015 Rob Rix. All rights reserved.

extension SequenceType {
	public func reduceRight<T>(initial: T, @noescape combine: (Generator.Element, T) -> T) -> T {
		func foldr(var generator: Generator, _ initial: T, @noescape _ combine: (Generator.Element, T) -> T) -> T {
			return generator.next().map { combine($0, foldr(generator, initial, combine)) } ?? initial
		}
		return foldr(generate(), initial, combine)
	}
}
