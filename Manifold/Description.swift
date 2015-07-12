//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var description: Module<Recur> {
		// Tag : λ _ : Enumeration . Type
		// Tag = λ E : Enumeration . λ _ : Boolean . Tag E

		let tag = Recur.Variable("Tag")
		let enumeration = Recur.Variable("Enumeration")
		let label = Recur.Variable("Label")
		let cons = Recur.Variable("::")


		let Tag = Binding("Tag",
			lambda(enumeration, .BooleanType) { E, _ in .Application(tag, E) },
			lambda(enumeration, const(.Type(0))))

		return Module([ list ], [
			Binding("String", .Axiom(String.self, .Type(0)), .Type(0)),
			Binding("Label", .Variable("String"), .Type(0)),
			Binding("Enumeration", .Application(.Variable("List"), .Variable("Label")), .Type(0)),

			Tag,
		])
	}
}


import Prelude
