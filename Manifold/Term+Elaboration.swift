//  Copyright © 2015 Rob Rix. All rights reserved.

extension String: ErrorType {}

extension Term {
	public func elaborateType(against: Term?, _ environment: [Name:Term], _ context: [Name:Term]) throws -> Elaborated {
		do {
			switch (out, against?.weakHeadNormalForm(environment).out) {
			case let (.Type(n), .None):
				return .Unroll(.Type(n + 1), .Type(n))

			case let (.Variable(name), .None):
				guard let type = context[name] else {
					throw "Unexpectedly free variable \(name) in context: \(Term.toString(context, separator: ":")), environment: \(Term.toString(environment, separator: "="))"
				}
				return .Unroll(type, .Variable(name))

			case let (.Application(a, b), .None):
				let a = try a.elaborateType(nil, environment, context)
				guard case let .Lambda(i, type, body) = a.type.weakHeadNormalForm(environment).out else {
					throw "Illegal application of \(self) : \(a.type) in context: \(Term.toString(context, separator: ":")), environment: \(Term.toString(environment, separator: "="))"
				}
				let bʹ = try b.elaborateType(type, environment, context)
				return .Unroll(body.substitute(i, b), .Application(a, bʹ))

			case let (.Lambda(i, .Some(a), b), .None):
				let aʹ = try a.elaborateType(.Type, environment, context)
				let bʹ = try b.elaborateType(nil, environment, context + [ .Local(i): a ])
				return .Unroll(a => { bʹ.type.substitute(i, $0) }, .Lambda(i, aʹ, bʹ))

			case let (.Type(m), .Some(.Type(n))) where n > m:
				return try elaborateType(nil, environment, context)

			case let (.Lambda(i, .Some(type), body), .Some(.Lambda(j, .Some(type2), bodyType))) where Term.equate(type, type2, environment):
				let t = try type.elaborateType(.Type, environment, context)
				let b = try body.elaborateType(bodyType.substitute(j, Term.Variable(Name.Local(i))), environment, context + [ Name.Local(i) : type ])
				return .Unroll(.Lambda(j, type2, bodyType), .Lambda(i, t, b))

			case let (.Lambda(i, .Some(type), body), .Some(.Type)):
				try type.elaborateType(.Type, environment, context)
				return try body.elaborateType(.Type, environment, context + [ Name.Local(i) : type ])

			case let (_, .Some(b)):
				let a = try elaborateType(nil, environment, context)
				guard Term.equate(a.type, Term(b), environment) else {
					throw "Type mismatch: expected '\(self)' to be of type '\(Term(b))', but it was actually of type '\(a.type)' in context: \(Term.toString(context, separator: ":")), environment: \(Term.toString(environment, separator: "="))"
				}
				return a

			default:
				throw "No rule to infer type of '\(self)'"
			}
		} catch let e {
			throw "\(e)\nin: '\(self)'" + (against.map { " ⇐ '\($0)'" } ?? " ⇒ ?")
		}
	}

	static func toString(table: [Name:Term], separator: String) -> String {
		let keys = table.keys.sort().lazy
		let maxLength: Int = keys.maxElement { $0.description.characters.count < $1.description.characters.count }?.description.characters.count ?? 0
		let padding: Character = " "
		let formattedContext = keys.map { "\(String(String($0), paddedTo: maxLength, with: padding)) \(separator) \(table[$0]!)" }.joinWithSeparator(",\n\t")

		return "[\n\t\(formattedContext)\n]"
	}
}
