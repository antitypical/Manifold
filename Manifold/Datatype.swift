//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Datatype<Recur: TermType>: DictionaryLiteralConvertible {
	indirect case Constructor(String, Telescope<Recur>, Datatype)
	case End

	public init(constructors: [(String, Telescope<Recur>)]) {
		self = constructors[constructors.indices].fold(.End) { .Constructor($0.0, $0.1, $1) }
	}

	public init(dictionaryLiteral: (String, Telescope<Recur>)...) {
		self.init(constructors: dictionaryLiteral)
	}


	public func definitions(recur: Recur, transform: Recur -> Recur = id) -> [(symbol: String, type: Recur -> Recur, value: Recur)] {
		let annotate: Recur -> Recur = { .Annotation($0, recur) }
		switch self {
		case .End:
			return []
		case let .Constructor(name, telescope, .End):
			return [ (name, telescope.type, telescope.value(recur, transform: transform >>> annotate)) ]
		case let .Constructor(name, telescope, rest):
			return [ (name, telescope.type, telescope.value(recur, transform: { .Product(true, $0) } >>> transform >>> annotate)) ] + rest.definitions(recur, transform: { .Product(false, $0) } >>> transform)
		}
	}


	public func value(recur: Recur) -> Recur {
		switch self {
		case .End:
			return .UnitType
		case let .Constructor(_, telescope, .End):
			return telescope.constructedType(recur)
		case let .Constructor(_, telescope, rest):
			return Recur.lambda(.BooleanType) {
				.If($0, telescope.constructedType(recur), rest.value(recur))
			}
		}
	}
}


import Prelude
