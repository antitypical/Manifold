//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Declaration<Recur: TermType>: CustomDebugStringConvertible, CustomStringConvertible {
	public init(_ symbol: String, type: Expression<Recur>, value: Expression<Recur>) {
		self = .Definition(symbol, type, value)
	}


	public var symbol: String {
		switch self {
		case let .Definition(symbol, _, _):
			return symbol
		case let .Datatype(symbol, _, _):
			return symbol
		}
	}


	public typealias DefinitionType = (symbol: String, type: Expression<Recur>, value: Expression<Recur>)

	public var definitions: [DefinitionType] {
		switch self {
		case let .Definition(symbol, type, value):
			return [ (symbol, type, value) ]
		case let .Datatype(symbol, type, datatype):
			let recur = Recur.Variable(.Global(symbol))
			return [ (symbol, type, datatype.value(recur).out) ] + datatype.definitions(recur)
		}
	}


	public var debugDescription: String {
		switch self {
		case let .Definition(symbol, type, value):
			return "\(symbol) : \(String(reflecting: type))\n"
				+ "\(symbol) = \(String(reflecting: value))"
		case let .Datatype(symbol, type, branches):
			return "data \(symbol) : \(String(reflecting: type)) = \(String(reflecting: branches))"
		}
	}

	public var description: String {
		switch self {
		case let .Definition(symbol, type, value):
			return "\(symbol) : \(type)\n"
				+ "\(symbol) = \(value)"
		case let .Datatype(symbol, type, branches):
			return "data \(symbol) : \(type) = \(branches)"
		}
	}


	case Definition(String, Expression<Recur>, Expression<Recur>)
	case Datatype(String, Expression<Recur>, Manifold.Datatype<Recur>)
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
