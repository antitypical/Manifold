//  Copyright © 2015 Rob Rix. All rights reserved.

extension String: ErrorType {}

extension Term {
	public func elaborateType(against: Term, _ environment: [Name:Term], _ context: [Name:Term]) throws -> AnnotatedTerm<Term> {
		do {
			switch (out, against.weakHeadNormalForm(environment).out) {
			case let (.Identity(.Type(n)), .Identity(.Implicit)):
				return .Unroll(.Type(n + 1), .Identity(.Type(n)))

			case let (.Variable(name), .Identity(.Implicit)):
				guard let type = context[name] else {
					throw "Unexpectedly free variable \(name) in context: \(Term.toString(context, separator: ":")), environment: \(Term.toString(environment, separator: "="))"
				}
				return .Unroll(type, .Variable(name))

			case let (.Identity(.Application(a, b)), .Identity(.Implicit)):
				let aʹ = try a.elaborateType(nil, environment, context)
				guard case let .Identity(.Lambda(type, body)) = aʹ.annotation.weakHeadNormalForm(environment).out else {
					throw "Illegal application of \(a) : \(aʹ.annotation) in context: \(Term.toString(context, separator: ":")), environment: \(Term.toString(environment, separator: "="))"
				}
				let bʹ = try b.elaborateType(type, environment, context)
				guard let (name, _) = body.scope else { return .Unroll(body, .Identity(.Application(aʹ, bʹ))) }
				return .Unroll(body.substitute(name, with: b), .Identity(.Application(aʹ, bʹ)))

			case let (.Identity(.Lambda(a, b)), .Identity(.Implicit)) where a != nil:
				let aʹ = try a.elaborateType(.Type, environment, context)
				if let (name, _) = b.scope {
					let bʹ = try b.elaborateType(nil, environment, context + [ name: a ])
					return .Unroll(a => { bʹ.annotation.substitute(name, with: $0) }, .Identity(.Lambda(aʹ, bʹ)))
				} else {
					let bʹ = try b.elaborateType(nil, environment, context)
					return .Unroll(bʹ.annotation, .Identity(.Lambda(aʹ, bʹ)))
				}

			case let (.Identity(.Embedded(value, eq, type)), .Identity(.Implicit)):
				let typeʹ = try type.elaborateType(.Type, environment, context)
				return .Unroll(type, .Identity(.Embedded(value, eq, typeʹ)))

			case let (.Identity(.Type(m)), .Identity(.Type(n))) where n > m:
				return try elaborateType(nil, environment, context)

			case let (.Identity(.Lambda(type, body)), .Identity(.Lambda(type2, bodyType))) where Term.equate(type, type2, environment) != nil:
				let t = try type2.elaborateType(.Type, environment, context)
				if let (name, _) = body.scope, (tName, _) = bodyType.scope {
					let b = try body.elaborateType(bodyType.substitute(tName, with: Term.Variable(name)), environment, context + [ name : type2 ])
					return .Unroll(.Lambda(type2, bodyType), .Identity(.Lambda(t, b)))
				} else if let (name, _) = body.scope {
					let b = try body.elaborateType(bodyType, environment, context + [ name : type2 ])
					return .Unroll(.Lambda(type2, bodyType), .Identity(.Lambda(t, b)))
				} else if let (tName, _) = bodyType.scope {
					let b = try body.elaborateType(bodyType, environment, context + [ tName: type2 ])
					return .Unroll(.Lambda(type2, bodyType), .Identity(.Lambda(t, b)))
				} else {
					let b = try body.elaborateType(bodyType, environment, context)
					return .Unroll(.Lambda(type2, bodyType), .Identity(.Lambda(t, b)))
				}

			case let (.Identity(.Lambda(type, body)), .Identity(.Type(n))):
				let typeʹ = try type.elaborateType(.Type, environment, context) ?? .Unroll(.Type(n + 1), .Identity(.Type(n)))
				return .Unroll(.Lambda(.Type, .Type), .Identity(.Lambda(typeʹ, try body.elaborateTypeInScope(type, .Type, environment, context))))

			case let (.Abstraction(_, body), _):
				return try body.elaborateType(against, environment, context)

			case (_, .Identity(.Implicit)):
				throw "No rule to infer type of '\(self)'"

			case let (.Identity(.Implicit), .Identity(type)):
				return .Unroll(Term(type), .Identity(.Implicit))

			case let (_, b):
				let a = try elaborateType(nil, environment, context)
				guard Term.equate(a.annotation, Term(b), environment) != nil else {
					throw "Type mismatch: expected '\(self)' to be of type '\(Term(b))', but it was actually of type '\(a.annotation)' in context: \(Term.toString(context, separator: ":")), environment: \(Term.toString(environment, separator: "="))"
				}
				return a
			}
		} catch let e {
			throw "\(e)\nin: '\(self)'" + (against == nil ? " ⇒ ?" : " ⇐ '\(against)'")
		}
	}

	func elaborateTypeInScope(type: Term, _ against: Term, _ environment: [Name:Term], _ context: [Name:Term]) throws -> AnnotatedTerm<Term> {
		if let (name, scope) = scope {
			return try elaborateType(against, environment, context + [ name: type ])
		} else {
			return try elaborateType(against, environment, context)
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
