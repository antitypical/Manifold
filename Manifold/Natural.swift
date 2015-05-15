//  Copyright (c) 2015 Rob Rix. All rights reserved.

public let naturalEnvironment: Environment = [
	"Natural": .Type,
	"Zero": Value.constant(0, .Free("Natural")),
	"Successor": Value.pi(Value.Free("Natural")) { $0.constant.flatMap { i, t in (i as? Int).map { ($0 + 1, t) } }.map(Value.constant) ?? $0 },
]
