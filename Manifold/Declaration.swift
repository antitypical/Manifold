//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Declaration<Recur>: CustomDebugStringConvertible, CustomStringConvertible {
	public init(_ symbol: String, type: Expression<Recur>, value: Expression<Recur>) {
		self.symbol = symbol
		self.type = type
		self.value = value
	}

	public let symbol: String
	public let type: Expression<Recur>
	public let value: Expression<Recur>


	public var debugDescription: String {
		return "\(symbol) : \(String(reflecting: type))\n\(symbol) = \(String(reflecting: value))"
	}


	public var description: String {
		return "\(symbol) : \(type)\n\(symbol) = \(value)"
	}
}

extension Declaration where Recur: FixpointType {
	public var ref: Recur {
		return Recur(.Variable(Name.Global(symbol)))
	}

	public func typecheck(environment: Expression<Recur>.Environment, _ context: Expression<Recur>.Context) -> Either<Error, Expression<Recur>> {
		return type.checkIsType(environment, context)
			>> value.checkType(type.evaluate(environment), environment, context)
				.either(
					ifLeft: { Either.left($0.map { "\(self.symbol)\n\t: \(self.type)\n\t= \(self.value)\n: " + $0 }) },
					ifRight: Either.right)
	}
}


import Either
