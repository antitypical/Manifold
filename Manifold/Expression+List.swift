//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var list: Module<Recur> {
		let List = Recur("List")

		// List : λ A : Type . Type
		// List = λ A : Type . λ tag : Boolean . if tag then (A, List A) else Unit
		let list = Declaration("List",
			type: lambda(.Type, const(.Type)),
			value: lambda(.Type) { A in Recur.lambda(.BooleanType) { .If($0, .Product(A, List[A]), .UnitType) } })

		// [] : λ A : Type . List A
		// [] = λ A : Type . (false, ()) : List A
		let `nil` = Declaration("[]",
			type: lambda(.Type) { A in List[A] },
			value: lambda(.Type) { A in .Annotation(Recur.Product(.Boolean(false), .Unit), List[A]) })

		// (::) : λ A : Type . λ _ : A . λ _ : List A . List A
		// (::) = λ A : Type . λ first : A . λ rest : List A . (true, (first, rest)) : List A
		let cons = Declaration("::",
			type: lambda(.Type) { A in .lambda(A, const(.lambda(List[A], const(List[A])))) },
			value: lambda(.Type) { A in Recur.lambda(A) { first in Recur.lambda(.Application(List, A)) { rest in .Annotation(.Product(.Boolean(true), .Product(first, rest)), List) } } })

		// uncons : λ A : Type . λ B : Type . λ ifCons : (λ _ : A . λ _ : List A . B) . λ ifNil : (λ _ : Unit . B) . λ list : List A . B
		// uncons = λ A : Type . λ B : Type . λ ifCons : (λ _ : A . λ _ : List A . B) . λ ifNil : (λ _ : Unit . B) . λ list : List A . if list.0 then ifCons list.1.0 list.1.1 else ifNil ()
		let uncons = Declaration("uncons",
			type: lambda(.Type, .Type) { A, B in Recur.lambda(Recur.FunctionType(A, Recur.FunctionType(List[A], B)), Recur.FunctionType(.UnitType, B), List[A]) { _ in B } },
			value: lambda(.Type, .Type) { A, B in Recur.lambda(Recur.FunctionType(A, Recur.FunctionType(List[A], B)), Recur.FunctionType(Recur.UnitType, B), List[A]) { ifCons, ifNil, list in .If(list.first, ifCons[list.second.first, list.second.second], ifNil[Recur.Unit]) } })

		return Module([ list, `nil`, cons, uncons ])
	}
}


import Prelude
