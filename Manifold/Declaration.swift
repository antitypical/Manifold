//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Declaration<Recur: TermType>: CustomDebugStringConvertible, CustomStringConvertible {
	public init(_ symbol: String, type: Recur, value: Recur) {
		self = .Definition(symbol, type, value)
	}

	public init(_ symbol: String, _ datatype: Manifold.Datatype<Recur>) {
		self = .Datatype(symbol, datatype)
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
			return [ (symbol, datatype.type(), datatype.value(recur)) ] + datatype.definitions(recur)
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
			return "data \(symbol) : \(datatype.type()) = \(datatype.value(.Variable(.Global(symbol))))"
		}
	}


	case Definition(String, Recur, Recur)
	case Datatype(String, Manifold.Datatype<Recur>)


	public var ref: Recur {
		return .Variable(Name.Global(symbol))
	}

	public func typecheck(environment: [Name:Recur], _ context: [Name:Recur]) -> [String] {
		switch self {
		case let .Definition(symbol, type, value):
			return (`catch` { try type.elaborateType(.Type, environment, context) }.map { [ "\(symbol) : τ ⇐ Type: \($0)" ] } ?? [])
				+ (`catch` { try value.elaborateType(type, environment, context) }.map { [ "\(symbol) ⇐ \(type): \($0)" ] } ?? [])
		case let .Datatype(symbol, _):
			return definitions
				.flatMap { definition, type, value in `catch` { try value.elaborateType(type, environment, context) }.map { "\(symbol).\(definition): \($0)" } }
		}
	}
}

private func `catch`(f: () throws -> ()) -> ErrorType? {
	do { try f() ; return nil }
	catch { return error }
}
