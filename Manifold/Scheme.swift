//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct Scheme {
	public init(_ variables: [Variable], _ type: Type) {
		self.variables = variables
		self.type = type
	}

	public let variables: [Variable]
	public let type: Type
}
