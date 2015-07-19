//  Copyright © 2015 Rob Rix. All rights reserved.

public enum List<Element>: ArrayLiteralConvertible, CollectionType, NilLiteralConvertible {
	case Nil
	case Cons(Element, () -> List)


	public var first: Element? {
		return uncons?.first
	}

	public var rest: List {
		return uncons?.rest ?? nil
	}

	public var uncons: (first: Element, rest: List)? {
		switch self {
		case let .Cons(first, rest):
			return (first, rest())
		case .Nil:
			return nil
		}
	}


	public init<S: SequenceType where S.Generator.Element == Element>(sequence: S) {
		self.init(generator: sequence.generate())
	}

	public init<G: GeneratorType where G.Element == Element>(var generator: G) {
		self = generator.next().map {
			.Cons($0, { List(generator: generator) })
			} ?? nil
	}


	// MARK: ArrayLiteralConvertible

	public init(arrayLiteral elements: Element...) {
		self.init(sequence: elements)
	}


	// MARK: NilLiteralConvertible

	public init(nilLiteral: ()) {
		self = Nil
	}


	// MARK: CollectionType

	public var startIndex: ListIndex<Element> {
		return ListIndex(list: self, index: isEmpty ? -1 : 0)
	}

	public var endIndex: ListIndex<Element> {
		return ListIndex(list: .Nil, index: -1)
	}

	public subscript (index: ListIndex<Element>) -> Element {
		return index.list.first!
	}
}

public struct ListIndex<Element>: ForwardIndexType {
	let list: List<Element>
	let index: Int

	public func successor() -> ListIndex {
		return ListIndex(list: list.rest, index: list.rest.isEmpty ? -1 : index + 1)
	}
}
