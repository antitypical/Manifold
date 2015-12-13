//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var string: Module {
		let List: Term = "List"
		let cons: Term = "cons"
		let `nil`: Term = "nil"

		let String = Declaration("String",
			type: .Type,
			value: .Embedded(Swift.String.self))

		let Character = Declaration("Character",
			type: .Type,
			value: .Embedded(Swift.Character.self))

		let embedCharacter: Swift.Character -> Term = { .Embedded($0, Character.ref) }
		func toTerm(characters: Swift.String.CharacterView) -> Term {
			guard let c = characters.first else { return `nil`[Character.ref] }
			return cons[Character.ref, embedCharacter(c), toTerm(characters.dropFirst())]
		}

		let toList = Declaration("toList",
			type: String.ref --> List[Character.ref],
			value: Term.Embedded("toList", String.ref --> List[Character.ref]) { (string: Swift.String) -> Term in
				toTerm(string.characters)
			})

		return Module("String", [ list ], [ String, Character, toList ])
	}
}
