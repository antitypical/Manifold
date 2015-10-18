//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Module<Recur: TermType> {
	public typealias Environment = [Name:Recur]
	public typealias Context = [Name:Recur]

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

	private var definitions: AnySequence<(Name, Recur, Recur)> {
		return AnySequence(declarations
			.lazy
			.flatMap {
				$0.definitions.lazy.map { symbol, type, value in
					(.Global(symbol), type, value)
				}
			})
	}

	public var environment: Environment {
		let dependencies = self.dependencies.lazy.map { $0.environment }
		let definitions = self.definitions.lazy.map { symbol, _, value in [ symbol: value ] }
		return dependencies
			.concat(definitions)
			.reduce(Environment(), combine: +)
	}

	public var context: Context {
		let dependencies = self.dependencies.lazy.map { $0.context }
		let definitions = self.definitions.lazy.map { symbol, type, _ in [ symbol: type ] }
		return dependencies
			.concat(definitions)
			.reduce(Context(), combine: +)
	}
}

extension Module where Recur: TermType {
	public func typecheck() -> [Error] {
		let environment = self.environment
		let context = self.context
		return declarations
			.lazy
			.flatMap { $0.typecheck(environment, context).map { $0.map { "\(self.name): \($0)" } } }
	}
}


import Either
