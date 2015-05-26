//  Copyright (c) 2015 Rob Rix. All rights reserved.

public let naturalEnvironment: Environment = [
	"Natural": .Type,
	"Zero": Value.forall { F in Value.forall { X in .pi(F, const(.pi(X, id))) } }, // ∀ F : Type . ∀ X : Type . λ f : F . λ x : X . x
	"Successor": Value.pi(Value.Free("Natural")) { $0.constant.flatMap { i, t in (i as? Int).map { ($0 + 1, t) } }.map(Value.constant) ?? $0 },
]


import Prelude
