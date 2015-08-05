//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Binding<Recur> {
	public init(_ symbol: Name, _ value: Expression<Recur>, _ type: Expression<Recur>) {
		self.symbol = symbol
		self.value = value
		self.type = type
	}

	public let symbol: Name
	public let value: Expression<Recur>
	public let type: Expression<Recur>
}

extension Binding where Recur: FixpointType {
	public func typecheck(environment: Expression<Recur>.Environment, _ context: Expression<Recur>.Context) -> Either<Error, Expression<Recur>> {
		return type.checkIsType(context)
			>> value.checkType(type, context: context)
				.either(
					ifLeft: { Either.left($0.map { "\(self.symbol)\n\t: \(self.type)\n\t= \(self.value)\n: " + $0 }) },
					ifRight: Either.right)
	}
}


import Either
