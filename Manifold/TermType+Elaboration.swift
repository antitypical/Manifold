//  Copyright © 2015 Rob Rix. All rights reserved.

extension String: ErrorType {}

extension Elaborated {
	private func ensureLambda(environment: [Name:Term]) throws -> (Int, Term, Term) {
		switch type.weakHeadNormalForm(environment).out {
		case let .Lambda(i, a, b):
			return (i, a, b)
		default:
			throw "Illegal application of \(term) : \(type)"
		}
	}
}

extension TermType {
	public func checkType(against: Self, _ environment: [Name:Self], _ context: [Name:Self]) -> Either<String, Elaborated<Self>> {
		return elaborateType(against, environment, context)
	}

	public func elaborateType(against: Self?, _ environment: [Name:Self], _ context: [Name:Self]) -> Either<String, Elaborated<Self>> {
		do {
			let (type, roll) = try elaborate(against, environment, context).destructure
			return .Right(.Unroll(against ?? type, roll))
		} catch let e {
			return .Left("\(e)\nin: '\(self)'" + (against.map { " ⇐ '\($0)'" } ?? " ⇒ ?"))
		}
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
			let (i, type, body) = try a.ensureLambda(environment)
			let b = try b.elaborate(type, environment, context)
			return .Unroll(body.substitute(i, b.term), .Application(a, b))

		case let (.Lambda(i, a, b), .None):
			let aʹ = try a.elaborate(.Type, environment, context)
			let bʹ = try b.elaborate(nil, environment, context + [ .Local(i): a ])
			return .Unroll(a => { bʹ.type.substitute(i, $0) }, .Lambda(i, aʹ, bʹ))

		case (.Type, .Some(.Type)):
			return try elaborate(nil, environment, context)

		case let (.Lambda(i, type1, body), .Some(.Lambda(j, type2, bodyType))) where Self.equate(type1, type2, environment):
			let t = try type1.elaborate(.Type, environment, context)
			let b = try body.elaborate(bodyType.substitute(j, Self.Variable(Name.Local(i))), environment, context + [ Name.Local(i) : type1 ])
			return .Unroll(.Lambda(j, type2, bodyType), .Lambda(i, t, b))

		case let (.Lambda(i, type, body), .Some(.Type)):
			try type.elaborate(.Type, environment, context)
			return try body.elaborate(.Type, environment, context + [ Name.Local(i) : type ])
			
		case let (_, .Some(b)):
			let a = try elaborate(nil, environment, context)
			guard Self.equate(a.type, Self(b), environment) else {
				throw "Type mismatch: expected '\(self)' to be of type '\(Self(b))', but it was actually of type '\(a.type)' in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))"
			}
			return a
		}
	}

	static func toString(table: [Name:Self], separator: String) -> String {
		let keys = table.keys.sort().lazy
		let maxLength: Int = keys.maxElement { $0.description.characters.count < $1.description.characters.count }?.description.characters.count ?? 0
		let padding: Character = " "
		let formattedContext = keys.map { "\(String(String($0), paddedTo: maxLength, with: padding)) \(separator) \(table[$0]!)" }.joinWithSeparator(",\n\t")

		return "[\n\t\(formattedContext)\n]"
	}
}


import Either
