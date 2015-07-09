//  Copyright © 2015 Rob Rix. All rights reserved.

extension SequenceType {
	public func scan<T>(initial: T, combine: (T, Generator.Element) -> T) -> [T] {
		return Array(lazy(self).scan(initial, combine: combine))
	}
}

public struct ScanSequenceView<Base: SequenceType, T>: SequenceType {
	init(sequence: Base, initial: T, combine: (T, Base.Generator.Element) -> T) {
		self.sequence = sequence
		self.initial = initial
		self.combine = combine
	}

	let sequence: Base
	let initial: T
	let combine: (T, Base.Generator.Element) -> T

	public func generate() -> AnyGenerator<T> {
		var current: T? = initial
		var generator = sequence.generate()
		let combine = self.combine
		return anyGenerator {
			current.map { into in
				current = generator.next().map { combine(into, $0) }
				return into
			}
		}
	}
}


public protocol LazySequenceType: SequenceType {
	typealias Sequence: SequenceType
}

extension LazySequenceType {
	public func scan<T>(initial: T, combine: (T, Generator.Element) -> T) -> LazySequence<ScanSequenceView<Self, T>> {
		return lazy(ScanSequenceView(sequence: self, initial: initial, combine: combine))
	}
}

extension LazySequence: LazySequenceType {
	public typealias Sequence = Base
}

extension LazyForwardCollection: LazySequenceType {
	public typealias Sequence = Base
}

extension LazyBidirectionalCollection: LazySequenceType {
	public typealias Sequence = Base
}

extension LazyRandomAccessCollection: LazySequenceType {
	public typealias Sequence = Base
}
