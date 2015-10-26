//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Declaration<Recur: TermType>: CustomStringConvertible {
	public init(_ symbol: String, type: Recur, value: Recur) {
		self = .Definition(symbol, type, value)
	}

	public init(_ symbol: String, _ datatype: Manifold.Datatype<Recur>) {
		self = .Datatype(symbol, datatype)
	}


	public var symbol: Name {
		switch self {
		case let .Definition(symbol, _, _):
			return .Global(symbol)
		case let .Datatype(symbol, _):
			return .Global(symbol)
		}
	}


	public typealias DefinitionType = (symbol: Name, type: Recur, value: Recur)

	public var definitions: [DefinitionType] {
		switch self {
		case let .Definition(symbol, type, value):
			return [ (.Global(symbol), type, value) ]
		case let .Datatype(symbol, datatype):
			let recur = Recur.Variable(.Global(symbol))
			return [ (.Global(symbol), datatype.type(), datatype.value(recur)) ] + datatype.definitions(recur)
		}
	}


	public var description: String {
		switch self {
		case let .Definition(symbol, type, value):
			return "\(symbol) : \(type)\n"
				+ "\(symbol) = \(value)"
		case let .Datatype(symbol, datatype):
			return "data \(symbol) : \(datatype.type()) = \(datatype.value(.Variable(.Global(symbol))))"
		}
	}


	case Definition(String, Recur, Recur)
	case Datatype(String, Manifold.Datatype<Recur>)


	public var ref: Recur {
		return .Variable(symbol)
	}
}
