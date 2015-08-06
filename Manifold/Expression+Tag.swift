//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var tag: Module<Recur> {
		let Tag = Recur("Tag")
		let Enumeration = Recur("Enumeration")
		let Label = Recur("Label")
		let cons = Recur("::")
		let uncons = Recur("uncons")
		let Branches = Recur("Branches")

		// Tag : λ _ : Enumeration . Type
		// Tag = λ E : Enumeration . λ _ : Boolean . Tag E
		let tag = Declaration("Tag",
			type: lambda(Enumeration, const(.Type(0))),
			value: lambda(Enumeration, .BooleanType) { E, c in .If(c, uncons[E, Recur.lambda(Label, Enumeration) { _, rest in rest }], .UnitType) })

		// here : λ first : Label . λ rest : Enumeration . Tag (first :: rest)
		// here = λ first : Label . (true, first) : Tag (first :: rest)
		let here = Declaration("here",
			type: lambda(Label, Enumeration) { first, rest in Tag[cons[first, rest]] },
			value: lambda(Label, Enumeration) { first, rest in .Annotation(.Product(.Boolean(false), .Unit), Tag[cons[first, rest]]) })

		// there : λ first : Label . λ rest : Enumeration . Tag (first :: rest)
		// there = λ first : Label . (false, rest) : Tag (first :: rest)
		let there = Declaration("there",
			type: lambda(Label, Enumeration) { first, rest in Tag[cons[first, rest]] },
			value: lambda(Label, Enumeration) { first, rest in Recur.lambda(Tag[rest]) { next in .Annotation(.Product(.Boolean(true), next), Tag[cons[first, rest]]) } })


		// Branches : λ E : Enumeration . λ _ : (λ _ : Tag E . Type) . Type
		// Branches = λ E : Enumeration . λ P : (λ _ : Tag E . Type) . if E.0
		//     then (P here, Branches E (λ t : Tag E . P (there t)))
		//     else Unit
		let branches = Declaration("Branches",
			type: lambda(Enumeration) { E in
				.lambda(.lambda(Tag[E], const(.Type)), const(.Type))
			},
			value: lambda(Enumeration) { E in
				Recur.lambda(.lambda(Tag[E], const(.Type))) { P in
					.If(E.first,
						.Product(
							P[Recur("here")],
							Branches[E, Recur.lambda(Tag[E]) { t in
								P[Recur("there")[t]]
							}]),
						.UnitType)
				}
			})

		// case : λ E : Enumeration . λ P : (λ _ : Tag E . Type) . λ cs : Branches E P . λ t : Tag E . P t
		// case = λ E : Enumeration . λ P : (λ _ : Tag E . Type) . λ cs : Branches E P . λ t : Tag E . if t.0
		//     then case E (λ t : Tag E . P (there t)) cs.1 t
		//     else cs.0
		let `case` = Declaration("case",
			type: lambda(Enumeration) { E in
				Recur.lambda(.lambda(Tag[E], const(.Type))) { P in
					.lambda(Branches[E, P], const(Recur.lambda(Tag[E]) { t in P[t] }))
				}
			},
			value: lambda(Enumeration) { E in
				Recur.lambda(Recur.lambda(Tag[E], const(.Type))) { P in
					Recur.lambda(Branches[E, P]) { cs in Recur.lambda(Tag[E]) { t in
						.If(t.first,
							Recur("case")[E, Recur.lambda(Tag[E]) { t in P[Recur("there")[t]] }, cs.second, t],
							cs.first)
					} }
				}
			})


		return Module([ list ], [
			Declaration("String", type: .Type(0), value: Axiom(String.self, .Type)),
			Declaration("Label", type: .Type(0), value: "String"),
			Declaration("Enumeration", type: .Type(0), value:
				Recur("List")[Label].out),

			tag,
			here,
			there,

			branches,
			`case`,
		])
	}
}


import Prelude
