//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Declaration: CustomStringConvertible {
	public init(_ symbol: Name, type: Term, value: Term) {
		self = .Definition(symbol, type, value)
	}

	public init(_ symbol: Name, _ datatype: Manifold.Datatype<Term>) {
		self = .Datatype(symbol, datatype)
	}


	public typealias DefinitionType = (symbol: Name, type: Term, value: Term)

	public var definitions: [DefinitionType] {
		switch self {
		case let .Definition(symbol, type, value):
			return [ (symbol, type, value) ]
		case let .Datatype(symbol, datatype):
			let recur = Term.Variable(symbol)
			return [ (symbol, datatype.type(), datatype.value(recur)) ] + datatype.definitions(recur)
		}
	}


	public var description: String {
		switch self {
		case let .Definition(symbol, type, value):
			return "\(symbol) : \(type)\n"
				+ "\(symbol) = \(value)"
		case let .Datatype(symbol, datatype):
			return "data \(symbol) : \(datatype.type()) = \(datatype.value(.Variable(symbol)))"
		}
	}


	case Definition(Name, Term, Term)
	case Datatype(Name, Manifold.Datatype<Term>)


	public var ref: Term {
		switch self {
		case let .Definition(symbol, _, _):
			return .Variable(symbol)
		case let .Datatype(symbol, _):
			return .Variable(symbol)
		}
	}
}
