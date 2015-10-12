//  Copyright © 2015 Rob Rix. All rights reserved.

public enum TypeConstructor<Recur: TermType>: DictionaryLiteralConvertible {
	case Argument(Recur, Recur -> TypeConstructor)
	case End(Datatype<Recur>)


	public init(dictionaryLiteral: (String, Telescope<Recur>)...) {
		self = .End(Datatype(constructors: dictionaryLiteral))
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
