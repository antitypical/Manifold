//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// An environment containing Church-encoded booleans.
public let booleanEnvironment: Environment = Environment([], [
	"Boolean": Value.pi(.type) { bool in Value.pi(bool, const(Value.pi(bool, const(bool)))) },
	"True": Value.pi(.free("Boolean")) { t in Value.pi(.free("Boolean"), const(t)) },
	"False": Value.pi(.free("Boolean")) { _ in Value.pi(.free("Boolean")) { f in f } },
])


import Prelude
