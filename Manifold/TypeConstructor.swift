//  Copyright © 2015 Rob Rix. All rights reserved.

public enum TypeConstructor<Recur: TermType>: DictionaryLiteralConvertible {
	indirect case Argument(Recur, Recur -> TypeConstructor)
	case End(Datatype<Recur>)


	public init(dictionaryLiteral: (String, Telescope<Recur>)...) {
		self = .End(Datatype(constructors: dictionaryLiteral))
	}


	public func definitions(recur: Recur, abstract: (Recur -> Recur) -> Recur -> Recur = { f in { f($0) } }) -> [Declaration<Recur>.DefinitionType] {
		switch self {
		case let .Argument(type, continuation):
			return continuation(0).definitions(recur, abstract: abstract >>> { f in { recur in Recur.lambda(type, { f(.Application(recur, $0)) }) } })
		case let .End(datatype):
			return datatype.definitions(recur).map { symbol, type, value in
				(symbol, abstract(type)(recur), abstract(value)(recur))
			}
		}
	}


	public func type(recur: Recur) -> Recur {
		switch self {
		case let .Argument(type, continuation):
			return Recur.lambda(type) {
				continuation($0).type(.Application(recur, $0))
			}
		case .End:
			return .Type
		}
	}


	public func value(recur: Recur) -> Recur {
		switch self {
		case let .Argument(type, continuation):
			return Recur.lambda(type) {
				continuation($0).value(.Application(recur, $0))
			}
		case let .End(datatype):
			return datatype.value(recur)
		}
	}
}


import Prelude
