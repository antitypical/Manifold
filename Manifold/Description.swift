//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var description: Module<Recur> {
		let tag = Recur("Tag")
		let enumeration = Recur("Enumeration")
		let label = Recur("Label")
		let cons = Recur("::")
		let branches = Recur("Branches")

		// Tag : λ _ : Enumeration . Type
		// Tag = λ E : Enumeration . λ _ : Boolean . Tag E
		let Tag = Binding("Tag",
			lambda(enumeration, .BooleanType) { E, _ in tag <| E },
			lambda(enumeration, const(.Type(0))))

		// here : λ first : Label . λ rest : Enumeration . Tag (first :: rest)
		// here = λ first : Label . (true, first) : Tag (first :: rest)
		let here = Binding("here",
			lambda(label, enumeration) { first, rest in .Annotation(.Product(.Boolean(false), .Unit), tag <| (cons <| first <| rest)) },
			lambda(label, enumeration) { first, rest in tag <| (cons <| first <| rest) })

		// there : λ first : Label . λ rest : Enumeration . Tag (first :: rest)
		// there = λ first : Label . (false, rest) : Tag (first :: rest)
		let there = Binding("there",
			lambda(label, enumeration) { first, rest in Recur.lambda(tag <| rest) { next in .Annotation(.Product(.Boolean(true), next), tag <| (cons <| first <| rest)) } },
			lambda(label, enumeration) { first, rest in tag <| (cons <| first <| rest) })


		// Branches : λ E : Enumeration . λ _ : (λ _ : Tag E . Type) . Type
		// Branches = λ E : Enumeration . λ P : (λ _ : Tag E . Type) . if E.0
		//     then (P here, Branches E (λ t : Tag E . P (there t)))
		//     else Unit
		let Branches = Binding("Branches",
			lambda(enumeration) { E in
				Recur.lambda(.lambda(tag <| E, const(.Type))) { P in
					.If(.Projection(E, false),
						.Product(
							P <| Recur("here"),
							branches <| E <| Recur.lambda(tag <| E) { t in
								P <| (Recur("there") <| t)
							}),
						.Unit)
				}
			},
			lambda(enumeration) { E in
				.lambda(.lambda(tag <| E, const(.Type)), const(.Type))
			})

		// case : λ E : Enumeration . λ P : (λ _ : Tag E . Type) . λ cs : Branches E P . λ t : Tag E . P t
		// case = λ E : Enumeration . λ P : (λ _ : Tag E . Type) . λ cs : Branches E P . λ t : Tag E . if t.0
		//     then case E (λ t : Tag E . P (there t)) cs.1 t
		//     else cs.0
		let `case` = Binding("case",
			lambda(enumeration) { E in
				Recur.lambda(Recur.lambda(tag <| E, const(.Type))) { P in
					Recur.lambda(branches <| E <| P) { cs in Recur.lambda(tag <| E) { t in
						.If(.Projection(t, false),
							Recur("case") <| E <| Recur.lambda(tag <| E) { t in P <| (Recur("there") <| t) } <| .Projection(cs, true) <| t,
							.Projection(cs, false))
					} }
				}
			},
			lambda(enumeration) { E in
				Recur.lambda(.lambda(tag <| E, const(.Type))) { P in
					.lambda(branches <| E <| P, const(Recur.lambda(tag <| E) { t in P <| t }))
				}
			})

		return Module([ list ], [
			Binding("String", .Axiom(String.self, .Type(0)), .Type(0)),
			Binding("Label", "String", .Type(0)),
			Binding("Enumeration", (Recur("List") <| label).out, .Type(0)),

			Tag,
			here,
			there,

			Branches,
			`case`,
		])
	}
}


import Prelude
