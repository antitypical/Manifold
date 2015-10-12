//  Copyright © 2015 Rob Rix. All rights reserved.

public enum TypeConstructor<Recur: TermType>: DictionaryLiteralConvertible {
	indirect case Argument(Recur, TypeConstructor)
	case End(Datatype<Recur>)


	public init(dictionaryLiteral: (String, Telescope<Recur>)...) {
		self = .End(Datatype(constructors: dictionaryLiteral))
	}


	public func definitions(recur: Recur, transform: Recur -> Recur = id) -> [Declaration<Recur>.DefinitionType] {
		return []
	}


	public func value(recur: Recur) -> Recur {
		switch self {
		case let .Argument(type, rest):
			return Recur.lambda(type) {
				rest.value(.Application(recur, $0))
			}
		case let .End(datatype):
			return datatype.value(recur)
		}
	}
}


import Prelude
