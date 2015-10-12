//  Copyright © 2015 Rob Rix. All rights reserved.

public enum TypeConstructor<Recur: TermType>: DictionaryLiteralConvertible {
	indirect case Argument(Recur, TypeConstructor)
	case End(Datatype<Recur>)


	public init(dictionaryLiteral: (String, Telescope<Recur>)...) {
		self = .End(Datatype(constructors: dictionaryLiteral))
	}


	public func definitions(recur: Recur, transform: Recur -> Recur = id) -> [Declaration<Recur>.DefinitionType] {
		switch self {
		case let .Argument(type, rest):
			return rest.definitions(recur, transform: transform)
		case let .End(datatype):
			return datatype.definitions(recur, transform: transform)
		}
	}


	public func type(recur: Recur) -> Recur {
		switch self {
		case let .Argument(type, rest):
			return Recur.lambda(type) {
				rest.type(.Application(recur, $0))
			}
		case .End:
			return .Type
		}
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
