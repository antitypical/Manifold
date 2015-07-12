//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var description: Module<Recur> {
		let tag = Recur.Variable("Tag")
		let enumeration = Recur.Variable("Enumeration")
		let label = Recur.Variable("Label")
		let cons = Recur.Variable("::")

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
			lambda(label, enumeration) { first, rest in Recur.lambda(.Application(tag, rest)) { _ in .Annotation(.Product(.Boolean(true), .Unit), .Application(.Application(cons, first), rest)) } },
			lambda(label, enumeration) { first, rest in .Application(tag, .Application(.Application(cons, first), rest)) })

		return Module([ list ], [
			Binding("String", .Axiom(String.self, .Type(0)), .Type(0)),
			Binding("Label", .Variable("String"), .Type(0)),
			Binding("Enumeration", .Application(.Variable("List"), .Variable("Label")), .Type(0)),

			Tag,
			here,
			there,
		])
	}
}


import Prelude
