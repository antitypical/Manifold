//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Environment {
	public init(_ local: [Term] = [], _ global: [Name: Term] = [:]) {
		self.local = local
		self.global = global
	}

	public let local: [Term]
	public let global: [Name: Term]


	public func byPrepending(value: Term) -> Environment {
		return Environment([ value ] + local, global)
	}
}

public func + (left: Environment, right: Environment) -> Environment {
	return Environment(left.local + right.local, left.global + right.global)
}
