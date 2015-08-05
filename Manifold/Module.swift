//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Module<Recur> {
	public typealias Environment = Expression<Recur>.Environment
	public typealias Context = Expression<Recur>.Context

	public init<D: SequenceType, S: SequenceType where D.Generator.Element == Module, S.Generator.Element == Declaration<Recur>>(_ dependencies: D, _ definitions: S) {
		self.dependencies = Array(dependencies)
		self.declarations = Array(definitions)
	}

	public init<S: SequenceType where S.Generator.Element == Declaration<Recur>>(_ definitions: S) {
		self.init([], definitions)
	}

	public let dependencies: [Module]
	public let declarations: [Declaration<Recur>]

	public var environment: Environment {
		let dependencies = lazy(self.dependencies).map { $0.environment }
		let definitions = lazy(self.declarations).map { [Name.Global($0.symbol): $0.value] }
		return dependencies
			.concat(definitions)
			.reduce(Environment(), combine: +)
	}

	public var context: Context {
		let dependencies = lazy(self.dependencies).map { $0.context }
		let definitions = lazy(self.declarations).map { [Name.Global($0.symbol): $0.type] }
		return dependencies
			.concat(definitions)
			.reduce(Context(), combine: +)
	}
}

extension Module where Recur: FixpointType {
	public func typecheck() -> [Error] {
		let environment = self.environment
		let context = self.context
		return lazy(declarations)
			.map { $0.typecheck(environment, context) }
			.reduce([]) { $0 + ($1.left.map { [ $0 ] } ?? []) }
	}
}


import Either
