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
	private func checkIsTypeElaborated(environment: [Name:Self], _ context: [Name:Self]) throws -> Elaborated<Self> {
		return try elaborate(.Type, environment, context)
	}

	private func elaborate(against: Self?, _ environment: [Name:Self], _ context: [Name:Self]) throws -> Elaborated<Self> {
		switch (out, against?.weakHeadNormalForm(environment).out) {
		case let (.Type(n), .None):
			return .Unroll(.Type(n + 1), .Type(n))

		case let (.Variable(name), .None):
			guard let type = context[name] else {
				throw "Unexpectedly free variable \(name) in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))"
			}
			return .Unroll(type, .Variable(name))

		case let (.Application(a, b), .None):
			let a = try a.elaborate(nil, environment, context)
			let (i, type, body) = try a.ensureLambda()
			let b = try b.elaborate(type.term, environment, context)
			return .Unroll(body.term.substitute(i, b.term), .Application(a, b))

		case (.Type, .Some(.Type)):
			return try elaborate(nil, environment, context)

		case let (.Lambda(i, type1, body), .Some(.Lambda(j, type2, bodyType))) where Self.equate(type1, type2, environment):
			try type1.checkIsTypeElaborated(environment, context)
			return try body.elaborate(bodyType.substitute(j, .Variable(.Local(i))), environment, context + [ Name.Local(i) : type1 ])

		case let (.Lambda(i, type, body), .Some(.Type)):
			try type.checkIsTypeElaborated(environment, context)
			return try body.checkIsTypeElaborated(environment, context + [ Name.Local(i) : type ])
			
		case let (_, .Some(b)):
			let a = try elaborate(nil, environment, context)
			guard Self.equate(a.type, Self(b), environment) else {
				throw "Type mismatch: expected '\(self)' to be of type '\(against)', but it was actually of type '\(a.type)' in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))"
			}
			return a

		default:
			throw "No rule to infer the type of '\(self)'"
		}
	}
}


import Either
