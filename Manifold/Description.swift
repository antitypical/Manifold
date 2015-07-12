//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var description: Module<Recur> {
		// Tag : λ _ : Enum . Type
		// Tag = λ E : Enum . λ _ : Boolean . Tag E
		let Tag = Binding("Tag",
			lambda(.Variable("Enum")) { E in Recur.lambda(.BooleanType) { _ in
				.Application(.Variable("Tag"), E)
			} },
			lambda(.Variable("Enum"), const(.Type(0))))

		return Module([ list ], [
			Binding("String", .Axiom(String.self, .Type(0)), .Type(0)),
			Binding("Label", .Variable("String"), .Type(0)),
			Binding("Enum", .Application(.Variable("List"), .Variable("Label")), .Type(0)),

			Tag,
		])
	}
}


import Prelude
