//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Module {
	public init<D: SequenceType, S: SequenceType where D.Generator.Element == Module, S.Generator.Element == Declaration<Term>>(_ name: String, _ dependencies: D, _ declarations: S) {
		self.name = name
		self.dependencies = Array(dependencies)
		self.definitions = declarations.flatMap { $0.definitions }
	}

	public init<S: SequenceType where S.Generator.Element == Declaration<Term>>(_ name: String, _ declarations: S) {
		self.init(name, [], declarations)
	}

	public let name: String

	public let dependencies: [Module]
	public let definitions: [(Name, Term, Term)]

	public var environment: [Name:Term] {
		return (dependencies.map { $0.environment }
			+ definitions.map { symbol, _, value in [ symbol: value ] })
			.reduce([:], combine: +)
	}

	public var context: [Name:Term] {
		return (dependencies.map { $0.context }
			+ definitions.map { symbol, type, _ in [ symbol: type ] })
			.reduce([:], combine: +)
	}

	public func typecheck() -> [String] {
		let environment = self.environment
		let context = self.context
		return definitions.flatMap { symbol, type, value -> [String] in
			do {
				try type.elaborateType(.Type, environment, context)
				try value.elaborateType(type, environment, context)
				return []
			} catch {
				return [ "\(self.name).\(symbol): \(error)" ]
			}
		}
	}
}
