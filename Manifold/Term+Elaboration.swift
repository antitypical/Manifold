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
				return .Unroll(body.applySubstitution(b), .Identity(.Application(aʹ, bʹ)))

			case let (.Identity(.Lambda(a, b)), .Identity(.Implicit)) where a != nil:
				let aʹ = try a.elaborateType(.Type, environment, context)
				let bʹ = try b.elaborateType(nil, environment, b.extendContext(context, with: a))
				return .Unroll(a => { bʹ.annotation.applySubstitution($0) }, .Identity(.Lambda(aʹ, bʹ)))

			case let (.Identity(.Embedded(value, eq, type)), .Identity(.Implicit)):
				let typeʹ = try type.elaborateType(.Type, environment, context)
				return .Unroll(type, .Identity(.Embedded(value, eq, typeʹ)))

			case let (.Identity(.Type(m)), .Identity(.Type(n))) where n > m:
				return try elaborateType(nil, environment, context)

			case let (.Identity(.Lambda(type1, body)), .Identity(.Lambda(type2, bodyType))):
				guard let _ = Term.equate(type1, type2, environment) else { throw "Unable to equate type '\(type1)' with expected type '\(type2)'" }
				let typeʹ = try type2.elaborateType(.Type, environment, context)

				let bodyTypeʹ = (body.scope?.0).map { bodyType.applySubstitution(.Variable($0)) } ?? bodyType
				let _ = try bodyTypeʹ.elaborateType(.Type, environment, body.extendContext(context, with: type2))

				let bodyʹ = try body.elaborateType(bodyTypeʹ, environment, body.extendContext(context, with: type2))
				return .Unroll(against, .Identity(.Lambda(typeʹ, bodyʹ)))

			case let (.Identity(.Lambda(type, body)), .Identity(.Type)):
				let typeʹ = try type.elaborateType(.Type, environment, context)
				return try .Unroll(.Type --> .Type, .Identity(.Lambda(typeʹ, body.elaborateType(.Type, environment, body.extendContext(context, with: type)))))

			case let (.Abstraction(name, scope), _):
				return try .Unroll(against, .Abstraction(name, scope.elaborateType(against, environment, context)))

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
			throw "\(e)\nin: '\(self)'" + (against == nil ? " ⇒ ?" : " ⇐ '\(against)' ('\(against.weakHeadNormalForm(environment) as Term)')")
		}
	}

	func extendContext(context: [Name:Term], with: Term) -> [Name:Term] {
		if let (name, _) = scope {
			return context + [ name: with ]
		}
		return context
	}

	static func toString(table: [Name:Term], separator: String) -> String {
		let keys = table.keys.sort().lazy
		let maxLength: Int = keys.maxElement { $0.description.characters.count < $1.description.characters.count }?.description.characters.count ?? 0
		let padding: Character = " "
		let formattedContext = keys.map { "\(String(String($0), paddedTo: maxLength, with: padding)) \(separator) \(table[$0]!)" }.joinWithSeparator(",\n\t")

		return "[\n\t\(formattedContext)\n]"
	}
}
