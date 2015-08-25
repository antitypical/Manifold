//  Copyright © 2015 Rob Rix. All rights reserved.

extension SequenceType {
	public func scan<T>(initial: T, combine: (T, Generator.Element) -> T) -> [T] {
		return Array(lazy.scan(initial, combine: combine))
	}
}

public struct LazyScanSequence<From, Into>: LazySequenceType {
	init<Base: SequenceType where Base.Generator.Element == From>(sequence: Base, initial: Into, combine: (Into, From) -> Into) {
		self.sequence = AnySequence(sequence)
		self.initial = initial
		self.combine = combine
	}

	let sequence: AnySequence<From>
	let initial: Into
	let combine: (Into, From) -> Into

	public func generate() -> AnyGenerator<Into> {
		var current: Into? = initial
		let generator = sequence.generate()
		let combine = self.combine
		return anyGenerator {
			current.map { into in
				current = generator.next().map { combine(into, $0) }
				return into
			}
		}
	}
}

extension LazySequenceType {
	public func scan<Into>(initial: Into, combine: (Into, Generator.Element) -> Into) -> LazyScanSequence<Generator.Element, Into> {
		return LazyScanSequence(sequence: self, initial: initial, combine: combine)
	}
}