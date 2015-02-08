//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Scheme {
	public init(_ variables: Set<Variable>, _ type: Type) {
		self.variables = variables
		self.type = type
	}

	public let variables: Set<Variable>
	public let type: Type


	public var freeVariables: Set<Variable> {
		return type.freeVariables - variables
	}
}


// MARK: - Imports

import Set
