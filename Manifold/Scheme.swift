//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Scheme: Equatable {
	public init(_ variables: Set<Variable>, _ type: Type) {
		self.variables = variables
		self.type = type
	}

	public let variables: Set<Variable>
	public let type: Type


	public var freeVariables: Set<Variable> {
		return type.freeVariables - variables
	}


	public func instantiate() -> Type {
		return Substitution(lazy(variables).map { ($0, Type(Variable())) }).apply(type)
	}
}

public func == (left: Scheme, right: Scheme) -> Bool {
	return left.variables == right.variables && left.type == right.type
}


// MARK: - Imports

import Set
