//  Copyright © 2015 Rob Rix. All rights reserved.

public typealias DefinitionType = (symbol: Name, type: Term, value: Term)

public enum Declaration: CustomStringConvertible {
	public init(_ symbol: Name, type: Term, value: Term) {
		self = .Definition(symbol, type, value)
	}

	public init(_ symbol: Name, _ datatype: Manifold.Datatype) {
		self = .Datatype(symbol, datatype)
	}


	public var definitions: [DefinitionType] {
		switch self {
		case let .Definition(symbol, type, value):
			return [ (symbol, type, value) ]
		case let .Datatype(symbol, datatype):
			return datatype.definitions(symbol)
		}
	}


	public var description: String {
		switch self {
		case let .Definition(symbol, type, value):
			return "\(symbol) : \(type)\n"
				+ "\(symbol) = \(value)"
		case let .Datatype(symbol, datatype):
			return "data \(symbol) : \(datatype.type()) = \(datatype.value(symbol))"
		}
	}


	case Definition(Name, Term, Term)
	case Datatype(Name, Manifold.Datatype)


	public var ref: Term {
		switch self {
		case let .Definition(symbol, _, _):
			return .Variable(symbol)
		case let .Datatype(symbol, _):
			return .Variable(symbol)
		}
	}
}
