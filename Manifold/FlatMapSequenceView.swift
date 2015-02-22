//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct FlatMapSequenceView<Base: SequenceType, Each: SequenceType>: SequenceType {
	private init(_ base: Base, _ transform: Base.Generator.Element -> Each) {
		self.base = base
		self.transform = transform
	}


	// MARK: SequenceType

	public func generate() -> GeneratorOf<Each.Generator.Element> {
		var outer = base.generate()
		var inner: Each.Generator?
		return GeneratorOf {
			next(
				{ () -> Each.Generator? in
					inner = outer.next().map(self.transform)?.generate()
					return inner
				},
				{ inner?.next() }
			)
		}
	}


	// MARK: Private

	private let base: Base
	private let transform: Base.Generator.Element -> Each
}

private func next<Each: GeneratorType>(outer: () -> Each?, inner: () -> Each.Element?) -> Each.Element? {
	return inner() ?? outer().map { _ in next(outer, inner) } ?? nil
}


public func flatMap<Base: SequenceType, Each: SequenceType>(base: Base, transform: Base.Generator.Element -> Each) -> FlatMapSequenceView<Base, Each> {
	return FlatMapSequenceView(base, transform)
}


extension LazySequence {
	func flatMap<Each: SequenceType>(transform: S.Generator.Element -> Each) -> LazySequence<FlatMapSequenceView<LazySequence<S>, Each>> {
		return lazy(FlatMapSequenceView(self, transform))
	}
}

extension LazyForwardCollection {
	func flatMap<Each: SequenceType>(transform: S.Generator.Element -> Each) -> LazySequence<FlatMapSequenceView<LazyForwardCollection<S>, Each>> {
		return lazy(FlatMapSequenceView(self, transform))
	}
}
