//  Copyright © 2015 Rob Rix. All rights reserved.

extension String: ErrorType {}

extension TermType {
	public func elaborateType(against: Self?, _ environment: [Name:Self], _ context: [Name:Self]) -> Either<String, Elaborated<Self>> {
		do {
			return .Right(try elaborate(against, environment, context))
		} catch let e {
			return .Left("\(e)\nin: '\(self)'" + (against.map { " ⇐ '\($0)'" } ?? " ⇒ ?"))
		}
	}

	public func elaborateType(against: Self?, _ environment: [Name:Self], _ context: [Name:Self]) throws -> Elaborated<Self> {
		do {
			switch (out, against?.weakHeadNormalForm(environment).out) {
			case let (.Type(n), .None):
				return .Unroll(.Type(n + 1), .Type(n))

			case let (.Variable(name), .None):
				guard let type = context[name] else {
					throw "Unexpectedly free variable \(name) in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))"
				}
				return .Unroll(type, .Variable(name))

			case let (.Application(a, b), .None):
				let a = try a.elaborateType(nil, environment, context)
				guard case let .Lambda(i, type, body) = a.type.weakHeadNormalForm(environment).out else {
					throw "Illegal application of \(self) : \(a.type) in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))"
				}
				let bʹ = try b.elaborateType(type, environment, context)
				return .Unroll(body.substitute(i, b), .Application(a, bʹ))

			case let (.Lambda(i, a, b), .None):
				let aʹ = try a.elaborateType(.Type, environment, context)
				let bʹ = try b.elaborateType(nil, environment, context + [ .Local(i): a ])
				return .Unroll(a => { bʹ.type.substitute(i, $0) }, .Lambda(i, aʹ, bʹ))

			case (.Type, .Some(.Type)):
				return try elaborateType(nil, environment, context)

			case let (.Lambda(i, type1, body), .Some(.Lambda(j, type2, bodyType))) where Self.equate(type1, type2, environment):
				let t = try type1.elaborateType(.Type, environment, context)
				let b = try body.elaborateType(bodyType.substitute(j, Self.Variable(Name.Local(i))), environment, context + [ Name.Local(i) : type1 ])
				return .Unroll(.Lambda(j, type2, bodyType), .Lambda(i, t, b))

			case let (.Lambda(i, type, body), .Some(.Type)):
				try type.elaborateType(.Type, environment, context)
				return try body.elaborateType(.Type, environment, context + [ Name.Local(i) : type ])

			case let (_, .Some(b)):
				let a = try elaborateType(nil, environment, context)
				guard Self.equate(a.type, Self(b), environment) else {
					throw "Type mismatch: expected '\(self)' to be of type '\(Self(b))', but it was actually of type '\(a.type)' in context: \(Self.toString(context, separator: ":")), environment: \(Self.toString(environment, separator: "="))"
				}
				return a
			}
		} catch let e {
			throw "\(e)\nin: '\(self)'" + (against.map { " ⇐ '\($0)'" } ?? " ⇒ ?")
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
