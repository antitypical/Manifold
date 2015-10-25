//  Copyright © 2015 Rob Rix. All rights reserved.

extension String: ErrorType {}

extension Elaborated {
	private func ensureLambda() throws -> (Int, Elaborated, Elaborated) {
		switch out {
		case let .Lambda(i, a, b):
			return (i, a, b)
		default:
			throw "Illegal application of \(term) : \(type)"
		}
	}
}

extension TermType {
	private func elaborate2(against: Self?, _ environment: [Name:Self], _ context: [Name:Self]) throws -> Elaborated<Self> {
		switch (out, against?.weakHeadNormalForm(environment).out) {
		case let (.Type(n), .None):
			return .Unroll(.Type(n + 1), .Type(n))

		case let (.Variable(name), .None):
			guard let type = context[name] else {
				throw "Unexpectedly free variable \(name) in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))"
			}
			return .Unroll(type, .Variable(name))

		case let (.Application(a, b), .None):
			let a = try a.elaborate2(nil, environment, context)
			let (i, type, body) = try a.ensureLambda()
			let b = try b.elaborate2(type.term, environment, context)
			return .Unroll(body.term.substitute(i, b.term), .Application(a, b))

		case let (_, .Some(b)):
			let a = try elaborate2(nil, environment, context)
			guard Self.equate(a.type, Self(b), environment) else {
				throw "Type mismatch: expected '\(self)' to be of type '\(against)', but it was actually of type '\(a.type)' in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))"
			}
			return a

		default:
			throw "unimplemented"
		}
	}
}


import Either
