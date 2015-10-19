//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Declaration<Recur: TermType>: CustomDebugStringConvertible, CustomStringConvertible {
	public init(_ symbol: String, type: Recur, value: Recur) {
		self = .Definition(symbol, type, value)
	}

	public init(_ symbol: String, _ datatype: TypeConstructor<Recur>) {
		self = .Datatype(symbol, datatype)
	}

	public init(_ symbol: String, _ type: Recur, _ constructor: Recur -> TypeConstructor<Recur>) {
		self.init(symbol, .Argument(type, constructor))
	}

	public init(_ symbol: String, _ type1: Recur, _ type2: Recur, _ constructor: (Recur, Recur) -> TypeConstructor<Recur>) {
		self.init(symbol, .Argument(type1, { a in .Argument(type2, { b in constructor(a, b) }) }))
	}


	public var symbol: String {
		switch self {
		case let .Definition(symbol, _, _):
			return symbol
		case let .Datatype(symbol, _):
			return symbol
		}
	}


	public typealias DefinitionType = (symbol: String, type: Recur, value: Recur)

	public var definitions: [DefinitionType] {
		switch self {
		case let .Definition(symbol, type, value):
			return [ (symbol, type, value) ]
		case let .Datatype(symbol, datatype):
			let recur = Recur.Variable(.Global(symbol))
			return [ (symbol, datatype.type(recur), datatype.value(recur)) ] + datatype.definitions(recur)
		}
	}


	public var debugDescription: String {
		switch self {
		case let .Definition(symbol, type, value):
			return "\(symbol) : \(String(reflecting: type))\n"
				+ "\(symbol) = \(String(reflecting: value))"
		case let .Datatype(symbol, datatype):
			return "data \(symbol) = \(String(reflecting: datatype))"
		}
	}

	public var description: String {
		switch self {
		case let .Definition(symbol, type, value):
			return "\(symbol) : \(type)\n"
				+ "\(symbol) = \(value)"
		case let .Datatype(symbol, datatype):
			let recur = Recur.Variable(.Global(symbol))
			return "data \(symbol) : \(datatype.type(recur)) = \(datatype.value(recur))"
		}
	}


	case Definition(String, Recur, Recur)
	case Datatype(String, TypeConstructor<Recur>)
}

extension Declaration {
	public var ref: Recur {
		return .Variable(Name.Global(symbol))
	}

	public func typecheck(environment: [Name:Recur], _ context: [Name:Recur]) -> [Error] {
		switch self {
		case let .Definition(symbol, type, value):
			return value.checkType(type, environment, context).left.map { [ $0.map { "\(symbol): \($0)" } ] } ?? []
		case let .Datatype(symbol, _):
			return definitions
				.flatMap { definition, type, value in value.checkType(type, environment, context).left.map { $0.map { "\(symbol).\(definition): \($0)" } } }
		}
	}
}


import Either
import Prelude
