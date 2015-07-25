//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var description: Module<Recur> {
		let Tag: Recur -> Recur = { Recur("Tag")[$0] }
		let Description = Recur("Description")
		let cons: (Recur, Recur) -> Recur = { Recur("::")[$0, $1] }
		let `nil` = Recur("[]")

		let label: String -> Recur = {
			.Axiom($0, Recur("String"))
		}

		let list: [Recur] -> Recur = fix { list in
			{ $0.uncons.map { cons($0, list(Array($1))) } ?? `nil` }
		}

		let here: (Recur, Recur) -> Recur = {
			Recur("here")[$0, $1]
		}

		let endTag = here(label("End"), list(["Recur", "Argument"].map(label)))

		// End : λ I : Type . λ _ : I . Description I
		// End = λ I : Type . λ i : I . (:End, i) : Description I
		let end = Binding("End",
			lambda(.Type) { I in Recur.lambda(I) { i in .Annotation(.Product(endTag, i), Description[I]) } },
			lambda(.Type) { I in Recur.lambda(I, const(Description[I])) })

		return Module([ Expression.list, tag ], [
			end,
		])
	}
}


import Prelude
