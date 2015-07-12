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
			lambda(enumeration, .BooleanType) { E, _ in .Application(tag, E) },
			lambda(enumeration, const(.Type(0))))

		// here : λ first : Label . λ rest : Enumeration . Tag (first :: rest)
		// here = λ first : Label . (true, first)
		let here = Binding("here",
			lambda(label, enumeration) { first, rest in .Annotation(.Product(.Boolean(false), .Unit), .Application(.Application(cons, first), rest)) },
			lambda(label, enumeration) { first, rest in .Application(tag, .Application(.Application(cons, first), rest)) })

		// there : λ first : Label . λ rest : Enumeration . Tag (first :: rest)
		// there = λ first : Label . (false, rest)
		let there = Binding("there",
			lambda(label, enumeration) { first, rest in Recur.lambda(.Application(tag, rest)) { next in .Annotation(.Product(.Boolean(true), next), .Application(.Application(cons, first), rest)) } },
			lambda(label, enumeration) { first, rest in .Application(tag, .Application(.Application(cons, first), rest)) })


		// Branches : λ E : Enumeration . λ _ : (λ _ : Tag E . Type) . Type
		// Branches = λ E : Enumeration . λ P : (λ _ : Tag E . Type) . if E.0
		//     then (P here, Branches E (λ t : Tag E . P (there t)))
		//     else Unit
		let Branches = Binding("Branches",
			lambda(enumeration) { E in
				Recur.lambda(.lambda(.Application(tag, E), const(.Type))) { P in
					.If(.Projection(E, false),
						.Product(
							.Application(P, Recur("here")),
							.Application(.Application(branches, E), Recur.lambda(.Application(tag, E)) { t in
								.Application(P, .Application(Recur("there"), t))
							})),
						.Unit)
				}
			},
			lambda(enumeration) { E in
				.lambda(.lambda(.Application(tag, E), const(.Type)), const(.Type))
			})

		return Module([ list ], [
			Binding("String", .Axiom(String.self, .Type(0)), .Type(0)),
			Binding("Label", "String", .Type(0)),
			Binding("Enumeration", .Application(.Variable("List"), label), .Type(0)),

			Tag,
			here,
			there,

			Branches,
		])
	}
}


import Prelude