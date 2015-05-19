//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// An environment containing Church-encoded booleans.
public let booleanEnvironment: Environment = [
	"Boolean": Value.pi(.Type) { bool in Value.pi(bool, const(Value.pi(bool, const(bool)))) },
]


import Prelude
