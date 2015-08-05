//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Declaration<Recur>: CustomDebugStringConvertible, CustomStringConvertible {
	public init(_ symbol: String, _ value: Expression<Recur>, _ type: Expression<Recur>) {
		self.symbol = symbol
		self.value = value
		self.type = type
	}

	public let symbol: String
	public let value: Expression<Recur>
	public let type: Expression<Recur>


	public var debugDescription: String {
		return "\(symbol) : \(String(reflecting: type))\n\(symbol) = \(String(reflecting: value))"
	}


	public var description: String {
		return "\(symbol) : \(type)\n\(symbol) = \(value)"
	}
}

extension Declaration where Recur: FixpointType {
	public func typecheck(environment: Expression<Recur>.Environment, _ context: Expression<Recur>.Context) -> Either<Error, Expression<Recur>> {
		return type.checkIsType(context)
			>> value.checkType(type.evaluate(environment), context: context)
				.either(
					ifLeft: { Either.left($0.map { "\(self.symbol)\n\t: \(self.type)\n\t= \(self.value)\n: " + $0 }) },
					ifRight: Either.right)
	}
}


import Either
