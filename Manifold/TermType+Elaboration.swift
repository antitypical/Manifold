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
	public func checkType(against: Self, _ environment: [Name:Self], _ context: [Name:Self]) -> Either<String, Elaborated<Self>> {
		return elaborateType(against, environment, context)
	}

	public func inferType(environment: [Name:Self] = [:], _ context: [Name:Self] = [:]) -> Either<String, Elaborated<Self>> {
		return elaborateType(nil, environment, context)
	}

	public func elaborateType(against: Self?, _ environment: [Name:Self], _ context: [Name:Self]) -> Either<String, Elaborated<Self>> {
		do {
			let (type, roll) = try elaborate(against, environment, context).destructure
			return .Right(.Unroll(against ?? type, roll))
		} catch let e {
			return .Left("\(e)\nin: '\(self)'" + (against.map { " ⇐ '\($0)'" } ?? " ⇒ ?"))
		}
	}

	func checkIsType(environment: [Name:Self], _ context: [Name:Self]) throws -> Elaborated<Self> {
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
			let _: Elaborated<Self> = try type1.checkIsType(environment, context)
			return try body.elaborate(bodyType.substitute(j, .Variable(.Local(i))), environment, context + [ Name.Local(i) : type1 ])

		case let (.Lambda(i, type, body), .Some(.Type)):
			let _: Elaborated<Self> = try type.checkIsType(environment, context)
			return try body.checkIsType(environment, context + [ Name.Local(i) : type ])
			
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

	static func toString(table: [Name:Self], separator: String) -> String {
		let keys = table.keys.sort().lazy
		let maxLength: Int = keys.maxElement { $0.description.characters.count < $1.description.characters.count }?.description.characters.count ?? 0
		let padding: Character = " "
		let formattedContext = keys.map { "\(String(String($0), paddedTo: maxLength, with: padding)) \(separator) \(table[$0]!)" }.joinWithSeparator(",\n\t")

		return "[\n\t\(formattedContext)\n]"
	}
}


import Either
