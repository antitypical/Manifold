//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var description: Module<Recur> {
		let Tag = Recur("Tag")
		let Enumeration = Recur("Enumeration")
		let Label = Recur("Label")
		let cons = Recur("::")
		let Branches = Recur("Branches")

		// Tag : λ _ : Enumeration . Type
		// Tag = λ E : Enumeration . λ _ : Boolean . Tag E
		let tag = Binding("Tag",
			lambda(Enumeration, .BooleanType) { E, _ in Tag[E] },
			lambda(Enumeration, const(.Type(0))))

		// here : λ first : Label . λ rest : Enumeration . Tag (first :: rest)
		// here = λ first : Label . (true, first) : Tag (first :: rest)
		let here = Binding("here",
			lambda(Label, Enumeration) { first, rest in .Annotation(.Product(.Boolean(false), .Unit), Tag[cons[first, rest]]) },
			lambda(Label, Enumeration) { first, rest in Tag[cons[first, rest]] })

		// there : λ first : Label . λ rest : Enumeration . Tag (first :: rest)
		// there = λ first : Label . (false, rest) : Tag (first :: rest)
		let there = Binding("there",
			lambda(Label, Enumeration) { first, rest in Recur.lambda(Tag[rest]) { next in .Annotation(.Product(.Boolean(true), next), Tag[cons[first, rest]]) } },
			lambda(Label, Enumeration) { first, rest in Tag[cons[first, rest]] })


		// Branches : λ E : Enumeration . λ _ : (λ _ : Tag E . Type) . Type
		// Branches = λ E : Enumeration . λ P : (λ _ : Tag E . Type) . if E.0
		//     then (P here, Branches E (λ t : Tag E . P (there t)))
		//     else Unit
		let branches = Binding("Branches",
			lambda(Enumeration) { E in
				Recur.lambda(.lambda(Tag[E], const(.Type))) { P in
					.If(E.first,
						.Product(
							P[Recur("here")],
							Branches[E, Recur.lambda(Tag[E]) { t in
								P[Recur("there")[t]]
							}]),
						.Unit)
				}
			},
			lambda(Enumeration) { E in
				.lambda(.lambda(Tag[E], const(.Type)), const(.Type))
			})

		// case : λ E : Enumeration . λ P : (λ _ : Tag E . Type) . λ cs : Branches E P . λ t : Tag E . P t
		// case = λ E : Enumeration . λ P : (λ _ : Tag E . Type) . λ cs : Branches E P . λ t : Tag E . if t.0
		//     then case E (λ t : Tag E . P (there t)) cs.1 t
		//     else cs.0
		let `case` = Binding("case",
			lambda(Enumeration) { E in
				Recur.lambda(Recur.lambda(Tag[E], const(.Type))) { P in
					Recur.lambda(Branches[E, P]) { cs in Recur.lambda(Tag[E]) { t in
						.If(t.first,
							Recur("case")[E, Recur.lambda(Tag[E]) { t in P[Recur("there")[t]] }, cs.second, t],
							cs.first)
					} }
				}
			},
			lambda(Enumeration) { E in
				Recur.lambda(.lambda(Tag[E], const(.Type))) { P in
					.lambda(Branches[E, P], const(Recur.lambda(Tag[E]) { t in P[t] }))
				}
			})

		return Module([ list ], [
			Binding("String", Axiom(String.self, .Type), .Type(0)),
			Binding("Label", "String", .Type(0)),
			Binding("Enumeration", Recur("List")[Label].out, .Type(0)),

			tag,
			here,
			there,

			branches,
			`case`,
		])
	}
}


import Prelude
