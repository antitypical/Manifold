//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Environment {
	public init(_ local: [Value] = [], _ global: [Name: Value] = [:]) {
		self.local = local
		self.global = global
	}

	public let local: [Value]
	public let global: [Name: Value]


	public func byPrepending(value: Value) -> Environment {
		return Environment([ value ] + local, global)
	}
}

public func + (left: Environment, right: Environment) -> Environment {
	return Environment(left.local + right.local, left.global + right.global)
}
