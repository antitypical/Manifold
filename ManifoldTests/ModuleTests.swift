//  Copyright © 2015 Rob Rix. All rights reserved.

final class ModuleTests: XCTestCase {
	func testModulesTypecheck() {
		for (_, module) in Module.modules {
			module.typecheck().forEach { XCTFail($0) }
		}
	}


	// MARK: Boolean

	func testEquivalenceOfEncodedAndDatatypeBooleans() {
		encodedBoolean.definitions.forEach { symbol, type, value in
			assert(Module.boolean.context[symbol], ==, type, message: "\(symbol)")
			assert(Module.boolean.environment[symbol], ==, value, message: "\(symbol)")
		}
	}


	// MARK: Natural

	func testZeroTypechecksAsNatural() {
		assert(try? zero.elaborateType(nil, Module.natural.environment, Module.natural.context), ==, .Unroll(Natural, .Variable(.Global("zero"))))
	}

	func testSuccessorOfZeroTypechecksAsNatural() {
		assert(try? successor[zero].elaborateType(nil, Module.natural.environment, Module.natural.context), ==, .Unroll(Natural, .Application(.Unroll(Natural --> Natural, .Variable(.Global("successor"))), .Unroll(Natural, .Variable(.Global("zero"))))))
	}


	// MARK: Pair

	func testEquivalenceOfEncodedAndDatatypePairs() {
		encodedPair.definitions.forEach { symbol, type, value in
			assert(Module.pair.context[symbol], ==, type, message: "\(symbol)")
			assert(Module.pair.environment[symbol], ==, value, message: "\(symbol)")
		}
	}


	// MARK: Sigma

	func testEquivalenceOfEncodedAndDatatypeSigmas() {
		encodedSigma.definitions.forEach { symbol, type, value in
			assert(Module.sigma.context[symbol], ==, type, message: "'\(symbol)' expected '\(type)', actual '\(Module.sigma.context[symbol])'")
			assert(Module.sigma.environment[symbol], ==, value, message: "'\(symbol)' expected '\(value)', actual '\(Module.sigma.environment[symbol])'")
		}
	}


	// MARK: Either

	func testEquivalenceOfEncodedAndDatatypeEithers() {
		Module.either.definitions.forEach { symbol, type, value in
			assert(encodedEither.context[symbol], ==, type, message: "\(symbol)")
			assert(encodedEither.environment[symbol], ==, value, message: "\(symbol)")
		}
	}


	// MARK: List

	func testEquivalenceOfEncodedAndDatatypeLists() {
		encodedList.definitions.forEach { symbol, type, value in
			assert(Module.list.context[symbol], ==, type, message: "'\(symbol)' expected '\(type)', actual '\(Module.list.context[symbol])'")
			assert(Module.list.environment[symbol], ==, value, message: "'\(symbol)' expected '\(value)', actual '\(Module.list.environment[symbol])'")
		}
	}


	// MARK: String

	func testStringToListConversion() {
		let environment = Module.string.environment
		let toList: Term = "toList"
		let String: Term = "String"
		let string = Term.Embedded("hi", String)
		let Character: Term = "Character"
		let cons: Term = "cons"
		let `nil`: Term = "nil"
		assert(try? toList[string].evaluate(environment), ==, try? cons[Character, embedCharacter("h"), cons[Character, embedCharacter("i"), `nil`[Character]]].evaluate(environment))
	}
}


private let encodedBoolean: Module = {
	let Boolean = Declaration("Boolean",
		type: .Type,
		value: .Type => { ($0, $0) => const($0) })

	let `true` = Declaration("true",
		type: Boolean.ref,
		value: .Type => { A in (A, A) => { a, _ in a } })

	let `false` = Declaration("false",
		type: Boolean.ref,
		value: .Type => { A in (A, A) => { _, b in b } })

	return Module("EncodedBoolean", [ Boolean, `true`, `false` ])
}()


private let Natural: Term = "Natural"
private let successor: Term = "successor"
private let zero: Term = "zero"


private let encodedPair: Module = {
	let Pair = Declaration("Pair",
		type: .Type --> .Type --> .Type,
		value: (.Type, .Type, .Type) => { A, B, Result in (A --> B --> Result) => const(Result) })

	let pair = Declaration("pair",
		type: (.Type, .Type) => { A, B in A --> B --> Pair.ref[A, B] },
		value: (.Type, .Type) => { A, B in (A, B, .Type) => { a, b, Result in (A --> B --> Result) => { f in f[a, b] } } })

	return Module("EncodedPair", [ Pair, pair, ])
}()


private let encodedSigma: Module = {
	let Sigma = Declaration("Sigma",
		type: .Type => { A in (A --> .Type) --> .Type },
		value: .Type => { A in (A --> .Type, .Type) => { B, C in (A => { x in B[x] --> C }) --> C } })

	let sigma = Declaration("sigma",
		type: .Type => { A in (A --> .Type, A) => { B, x in B[x] --> Sigma.ref[A, B] } },
		value: .Type => { A in (A --> .Type, A) => { B, x in (B[x], .Type) => { y, C in (A => { xʹ in B[xʹ] --> C }) => { f in f[x, y] } } } })

	return Module("EncodedSigma", [ Sigma, sigma ])
}()


private let encodedEither: Module = {
	let Either = Declaration("Either",
		type: .Type --> .Type --> .Type,
		value: (.Type, .Type, .Type) => { L, R, Result in (L --> Result) --> (R --> Result) --> Result })

	let left = Declaration("left",
		type: (.Type, .Type) => { L, R in L --> Either.ref[L, R] },
		value: (.Type, .Type) => { L, R in (L, .Type) => { (l: Term, Result) in ((L --> Result), (R --> Result)) => { ifL, _ in ifL[l] } } })

	let right = Declaration("right",
		type: (.Type, .Type) => { L, R in R --> Either.ref[L, R] },
		value: (.Type, .Type) => { L, R in (R, .Type) => { (r: Term, Result) in ((L --> Result), (R --> Result)) => { _, ifR in ifR[r] } } })

	return Module("EncodedEither", [ Either, left, right ])
}()


private let encodedList: Module = {
	let List: Term = "List"
	let list = Declaration("List",
		type: .Type --> .Type,
		value: (.Type, .Type) => { A, B in (A --> List[A] --> B) --> B --> B })

	let cons = Declaration("cons",
		type: .Type => { A in A --> List[A] --> List[A] },
		value: .Type => { A in (A, List[A], .Type) => { head, tail, B in (A --> List[A] --> B, B) => { ifCons, _ in ifCons[head, tail] } } })

	let `nil` = Declaration("nil",
		type: .Type => { (A: Term) in List[A] },
		value: (.Type, .Type) => { A, B in (A --> List[A] --> B, B) => { _, other in other } })

	return Module("EncodedList", [ list, cons, `nil` ])
}()

private let embedCharacter: Character -> Term = { Term.Embedded($0, "Character") }


import Assertions
import Manifold
import Prelude
import XCTest
