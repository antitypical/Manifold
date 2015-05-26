//  Copyright (c) 2015 Rob Rix. All rights reserved.

public let naturalEnvironment: Environment = [
	"Natural": Value.forall(const(Value.function(Value.function(.Type, .Type), Value.forall(const(.Type))))),
	"Zero": Value.forall { X in .pi(.function(X, X), const(.pi(X, id))) }, // ∀ X : Type . λ f : X → X . λ x : X . x
	"Successor": Value.pi(Value.Free("Natural")) { $0.constant.flatMap { i, t in (i as? Int).map { ($0 + 1, t) } }.map(Value.constant) ?? $0 },
]


import Prelude
