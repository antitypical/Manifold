//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Module<Recur: TermType> {
	public init<D: SequenceType, S: SequenceType where D.Generator.Element == Module, S.Generator.Element == Declaration<Recur>>(_ name: String, _ dependencies: D, _ declarations: S) {
		self.name = name
		self.dependencies = Array(dependencies)
		self.declarations = Array(declarations)
	}

	public init<S: SequenceType where S.Generator.Element == Declaration<Recur>>(_ name: String, _ declarations: S) {
		self.init(name, [], declarations)
	}

	public let name: String

	public let dependencies: [Module]
	public let declarations: [Declaration<Recur>]

	public var definitions: [(Name, Recur, Recur)] {
		return declarations.flatMap { $0.definitions }
	}

	public var environment: [Name:Recur] {
		return (dependencies.map { $0.environment }
			+ definitions.map { symbol, _, value in [ symbol: value ] })
			.reduce([:], combine: +)
	}

	public var context: [Name:Recur] {
		return (dependencies.map { $0.context }
			+ definitions.map { symbol, type, _ in [ symbol: type ] })
			.reduce([:], combine: +)
	}
}

extension Module where Recur: TermType {
	public func typecheck() -> [String] {
		let environment = self.environment
		let context = self.context
		return declarations
			.lazy
			.flatMap { $0.typecheck(environment, context).map { "\(self.name).\($0)" } }
	}
}
