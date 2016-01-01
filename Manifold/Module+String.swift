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
			guard let c = characters.first else { return `nil`[Term.Implicit] }
			return cons[nil, embedCharacter(c), toTerm(characters.dropFirst())]
		}

		let toList = Declaration("toList",
			type: String.ref --> List[Character.ref],
			value: Term.Embedded("toList", String.ref --> List[Character.ref]) { (string: Swift.String) -> Term in
				toTerm(string.characters)
			})

		let embedString: Swift.String -> Term = { .Embedded($0, String.ref) }
		let combine = Declaration("combine",
			type: Character.ref --> String.ref --> String.ref,
			value: Term.Embedded("combine1", Character.ref --> String.ref --> String.ref) { (c: Swift.Character) in
				Term.Embedded("combine2", String.ref --> String.ref) {
					Term.Embedded(Swift.String(c) + $0, String.ref)
				}
			})

		let fromList: Term = "fromList"
		let _fromList = Declaration("fromList",
			type: List[Character.ref] --> String.ref,
			value: nil => { list in list[nil, (nil, nil) => { c, rest in combine.ref[c, fromList[rest]] }, embedString("")] })

		return Module("String", [ list ], [ String, Character, toList, combine, _fromList ])
	}
}
