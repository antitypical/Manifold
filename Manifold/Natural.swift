//  Copyright (c) 2015 Rob Rix. All rights reserved.

//public let naturalEnvironment: Environment = Environment([], [
//	"Natural": Value.forall { X in Value.pi(Value.function(X, X), const(Value.pi(X, id))) },
//	"Zero": Value.forall { X in .pi(.function(X, X), const(.pi(X, id))) }, // ∀ X : Type . λ f : X → X . λ x : X . x
//	"One": Value.forall { X in Value.pi(.function(X, X)) { f in Value.pi(X) { x in f.apply(x) } } }, // ∀ F : Type . ∀ X : Type . λ f : F . λ x : X . f(x)
//	"Successor": Value.forall { N in Value.forall { X in Value.pi(N) { n in Value.pi(.function(X, X)) { f in Value.pi(X) { x in f.apply(n.apply(f).apply(x)) } } } } }, // ∀ N . ∀ F . ∀ X . λ n : N . λ f : F . λ x : X . f ((n f) x)
//])


import Prelude
