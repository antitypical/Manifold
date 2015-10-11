//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Declaration<Recur: TermType>: CustomDebugStringConvertible, CustomStringConvertible {
	public init(_ symbol: String, type: Expression<Recur>, value: Expression<Recur>) {
		self = .Definition(symbol, type, value)
	}


	public var symbol: String {
		switch self {
		case let .Definition(symbol, _, _):
			return symbol
		case let .Datatype(symbol, _):
			return symbol
		}
	}

	public var type: Expression<Recur> {
		switch self {
		case let .Definition(_, type, _):
			return type
		case .Datatype:
			return .Type(0)
		}
	}

	public var value: Expression<Recur> {
		switch self {
		case let .Definition(_, _, value):
			return value
		case let .Datatype(_, datatype):
			return datatype.value(.Variable(.Global(symbol))).out
		}
	}


	public typealias DefinitionType = (symbol: String, type: Expression<Recur>, value: Expression<Recur>)

	public var definitions: [DefinitionType] {
		switch self {
		case let .Definition(symbol, type, value):
			return [ (symbol, type, value) ]
		case let .Datatype(symbol, datatype):
			return [ (symbol, type, value) ] + datatype.definitions(.Variable(.Global(symbol)))
		}
	}


	public var debugDescription: String {
		switch self {
		case let .Definition(symbol, type, value):
			return "\(symbol) : \(String(reflecting: type))\n"
				+ "\(symbol) = \(String(reflecting: value))"
		case let .Datatype(symbol, branches):
			return "data \(symbol) = \(String(reflecting: branches))"
		}
	}

	public var description: String {
		switch self {
		case let .Definition(symbol, type, value):
			return "\(symbol) : \(type)\n"
				+ "\(symbol) = \(value)"
		case let .Datatype(symbol, branches):
			return "data \(symbol) = \(branches)"
		}
	}


	case Definition(String, Expression<Recur>, Expression<Recur>)
	case Datatype(String, Manifold.Datatype<Recur>)
}

extension Declaration where Recur: TermType {
	public var ref: Recur {
		return .Variable(Name.Global(symbol))
	}

	public func typecheck(environment: Expression<Recur>.Environment, _ context: Expression<Recur>.Context) -> [Error] {
		return definitions.flatMap { $2.checkType($1, environment, context).left }
	}
}


import Either
import Prelude
