//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// An environment containing Church-encoded booleans.
public let booleanEnvironment: [Name: Value] = [
	"Boolean": Value.pi(.Type) { bool in Value.pi(bool, const(Value.pi(bool, const(bool)))) },
	"True": Value.pi(.parameter("Boolean")) { t in Value.pi(.parameter("Boolean"), const(t)) },
	"False": Value.pi(.parameter("Boolean")) { _ in Value.pi(.parameter("Boolean")) { f in f } },
]


import Prelude
