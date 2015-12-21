//  Copyright © 2015 Rob Rix. All rights reserved.

extension String: ErrorType {}

extension Term {
	public func elaborateType(against: Term, _ environment: [Name:Term], _ context: [Name:Term]) throws -> AnnotatedTerm<Term> {
		do {
			switch (out, against.weakHeadNormalForm(environment).out) {
			case let (.Type(n), .Implicit):
				return .Unroll(.Type(n + 1), .Type(n))

			case let (.Variable(name), .Implicit):
				guard let type = context[name] else {
					throw "Unexpectedly free variable \(name) in context: \(Term.toString(context, separator: ":")), environment: \(Term.toString(environment, separator: "="))"
				}
				return .Unroll(type, .Variable(name))

			case let (.Application(a, b), .Implicit):
				let aʹ = try a.elaborateType(nil, environment, context)
				guard case let .Lambda(i, type, body) = aʹ.annotation.weakHeadNormalForm(environment).out else {
					throw "Illegal application of \(a) : \(aʹ.annotation) in context: \(Term.toString(context, separator: ":")), environment: \(Term.toString(environment, separator: "="))"
				}
				let bʹ = try b.elaborateType(type, environment, context)
				return .Unroll(body.substitute(i, b), .Application(aʹ, bʹ))

			case let (.Lambda(i, a, b), .Implicit) where a != nil:
				let aʹ = try a.elaborateType(.Type, environment, context)
				let bʹ = try b.elaborateType(nil, environment, context + [ .Local(i): a ])
				return .Unroll(a => { bʹ.annotation.substitute(i, $0) }, .Lambda(i, aʹ, bʹ))

			case let (.Embedded(value, eq, type), .Implicit):
				let typeʹ = try type.elaborateType(.Type, environment, context)
				return .Unroll(type, .Embedded(value, eq, typeʹ))

			case let (.Type(m), .Type(n)) where n > m:
				return try elaborateType(nil, environment, context)

			case let (.Lambda(i, type, body), .Lambda(j, type2, bodyType)) where Unification(type, type2, environment).unified != nil:
				let t = try type2.elaborateType(.Type, environment, context)
				let b = try body.elaborateType(bodyType.substitute(j, Term.Variable(Name.Local(i))), environment, context + [ Name.Local(i) : type2 ])
				return .Unroll(.Lambda(j, type2, bodyType), .Lambda(i, t, b))

			case let (.Lambda(i, type, body), .Type(n)):
				let typeʹ = try type.elaborateType(.Type, environment, context) ?? .Unroll(.Type(n + 1), .Type(n))
				return .Unroll(.Lambda(i, .Type, .Type), .Lambda(i, typeʹ, try body.elaborateType(.Type, environment, context + [ Name.Local(i) : type ?? .Type(n) ])))

			case (.Implicit, .Implicit):
				throw "No rule to infer type of '\(self)'"

			case let (.Implicit, type):
				return .Unroll(Term(type), .Implicit)

			case let (_, b):
				let a = try elaborateType(nil, environment, context)
				let unification = Unification(a.annotation, Term(b), environment)
				guard unification.unified != nil else {
					throw "Type mismatch for '\(self)':\n\(unification)\nin context: \(Term.toString(context, separator: ":")),\nenvironment: \(Term.toString(environment, separator: "="))"
				}
				return a
			}
		} catch let e {
			throw "\(e)\nin: '\(self)'" + (against == nil ? " ⇒ ?" : " ⇐ '\(against)'")
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
