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

		return Module("String", [ String, Character ])
		func toTerm(characters: Swift.String.CharacterView) -> Term {
			switch characters.first {
			case let .Some(c):
				return cons[Character.ref, .Embedded(c), toTerm(characters.dropFirst())]
			default:
				return `nil`[Character.ref]
			}
		}
	}
}
