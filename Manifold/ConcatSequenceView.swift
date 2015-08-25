//  Copyright © 2015 Rob Rix. All rights reserved.

extension SequenceType {
	public func concat<S: SequenceType where S.Generator.Element == Generator.Element>(other: S) -> [Generator.Element] {
		return Array(lazy.concat(other))
	}
}

public struct ConcatSequenceView<T>: SequenceType {
	init<A: SequenceType, B: SequenceType where A.Generator.Element == T, B.Generator.Element == T>(_ a: A, _ b: B) {
		self.a = AnySequence(a)
		self.b = AnySequence(b)
	}

	let a: AnySequence<T>
	let b: AnySequence<T>

	public func generate() -> AnyGenerator<T> {
		let a = self.a.generate()
		let b = self.b.generate()

		return anyGenerator {
			a.next() ?? b.next()
		}
	}
}

extension LazySequenceType {
	public func concat<S: SequenceType where S.Generator.Element == Generator.Element>(other: S) -> LazySequence<ConcatSequenceView<Generator.Element>> {
		return lazy(ConcatSequenceView(self, other))
	}
}
