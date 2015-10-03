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
			return Description(branches: datatype.branches).type(.Variable(.Global(symbol))).map(Recur.init)
		}
	}


	public typealias DefinitionType = (symbol: String, type: Expression<Recur>, value: Expression<Recur>)

	public var definitions: [DefinitionType] {
		switch self {
		case let .Definition(symbol, type, value):
			return [ (symbol, type, value) ]
		case let .Datatype(symbol, datatype):
			let recur: Expression<Description> = .Variable(.Global(symbol))
			let description = Description(datatype: datatype)
			return [ (symbol, .Type(0), description.type(recur).map(Recur.init)) ]
				+ datatype.branches.map { ($0, recur.map(Recur.init), $1.value(recur).map(Recur.init)) }
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
	case Datatype(String, Manifold.Datatype)
}

extension Declaration where Recur: TermType {
	public var ref: Recur {
		return .Variable(Name.Global(symbol))
	}

	public func typecheck(environment: Expression<Recur>.Environment, _ context: Expression<Recur>.Context) -> Either<Error, Expression<Recur>> {
		return type.checkIsType(environment, context)
			>> value.checkType(type.evaluate(environment), environment, context)
				.either(
					ifLeft: { Either.left($0.map { "\(self.symbol)\n\t: \(self.type)\n\t= \(self.value)\n: " + $0 }) },
					ifRight: Either.right)
	}
}

/// Helper type to enable construction of datatype Declarations with a dictionary literal.
public struct Datatype: DictionaryLiteralConvertible {
	public init(branches: [(String, Description)]) {
		self.branches = branches
	}

	public init(dictionaryLiteral elements: (String, Description)...) {
		self.init(branches: elements)
	}

	public let branches: [(String, Description)]
}


import Either
