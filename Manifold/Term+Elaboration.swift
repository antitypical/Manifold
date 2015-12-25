//  Copyright © 2015 Rob Rix. All rights reserved.

extension String: ErrorType {}

extension Term {
	public func elaborateType(against: Term, _ environment: [Name:Term], _ context: [Name:Term]) throws -> AnnotatedTerm<Term> {
		return try elaborateUnification(against, environment, context).map {
			guard let unified = $0.unified else { throw $0.description }
			return unified
		}
	}

	public func elaborateUnification(against: Term, _ environment: [Name:Term], _ context: [Name:Term]) throws -> AnnotatedTerm<Unification> {
		do {
			switch (out, against.weakHeadNormalForm(environment).out) {
			case let (.Type(n), .Implicit):
				return .Unroll(Unification(.Type(n + 1)), .Type(n))

			case let (.Variable(name), .Implicit):
				guard let type = context[name] else {
					throw "Unexpectedly free variable \(name) in context: \(Term.toString(context, separator: ":")), environment: \(Term.toString(environment, separator: "="))"
				}
				return .Unroll(Unification(type), .Variable(name))

			case let (.Application(a, b), .Implicit):
				let aʹ = try a.elaborateUnification(nil, environment, context)
				guard case let .Lambda(i, type, body) = aʹ.annotation.actual.weakHeadNormalForm(environment).out else {
					throw "Illegal application of \(a) : \(aʹ.annotation) in context: \(Term.toString(context, separator: ":")), environment: \(Term.toString(environment, separator: "="))"
				}
				let bʹ = try b.elaborateUnification(type, environment, context)
				return .Unroll(Unification(body.substitute(i, b)), .Application(aʹ, bʹ))

			case let (.Lambda(i, a, b), .Implicit) where a != nil:
				let aʹ = try a.elaborateUnification(.Type, environment, context)
				let bʹ = try b.elaborateUnification(nil, environment, context + [ .Local(i): a ])
				return .Unroll(Unification(a => { bʹ.annotation.actual.substitute(i, $0) }), .Lambda(i, aʹ, bʹ))

			case let (.Embedded(value, eq, type), .Implicit):
				let typeʹ = try type.elaborateUnification(.Type, environment, context)
				return .Unroll(Unification(type), .Embedded(value, eq, typeʹ))

			case let (.Type(m), .Type(n)) where n > m:
				return try elaborateUnification(nil, environment, context)

			case let (.Lambda(i, type, body), .Lambda(j, type2, bodyType)) where Unification(type, type2, environment).unified != nil:
				let t = try type2.elaborateUnification(.Type, environment, context)
				let b = try body.elaborateUnification(bodyType.substitute(j, Term.Variable(Name.Local(i))), environment, context + [ Name.Local(i) : type2 ])
				return .Unroll(Unification(.Lambda(j, type2, bodyType)), .Lambda(i, t, b))

			case let (.Lambda(i, type, body), .Type(n)):
				let typeʹ = try type.elaborateUnification(.Type, environment, context) ?? .Unroll(Unification(.Type(n + 1)), .Type(n))
				return .Unroll(Unification(.Lambda(i, .Type, .Type)), .Lambda(i, typeʹ, try body.elaborateUnification(.Type, environment, context + [ Name.Local(i) : type ?? .Type(n) ])))

			case (.Implicit, .Implicit):
				throw "No rule to infer type of '\(self)'"

			case let (.Implicit, type):
				return .Unroll(Unification(Term(type)), .Implicit)

			case let (_, b):
				let a = try elaborateUnification(nil, environment, context)
				let unification = Unification(a.annotation.actual, Term(b), environment)
				guard unification.unified != nil else {
					throw "Type mismatch for '\(self)':\n\(unification)in context: \(Term.toString(context, separator: ":")),\nenvironment: \(Term.toString(environment, separator: "="))"
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
