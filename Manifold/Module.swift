//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Module<Recur> {
	public typealias Environment = Expression<Recur>.Environment
	public typealias Context = Expression<Recur>.Context

	public init<D: SequenceType, S: SequenceType where D.Generator.Element == Module, S.Generator.Element == Binding<Recur>>(_ dependencies: D, _ definitions: S) {
		self.dependencies = Array(dependencies)
		self.definitions = Array(definitions)
	}

	public let dependencies: [Module]
	public let definitions: [Binding<Recur>]

	public var environment: Environment {
		let dependencies = lazy(self.dependencies).map { $0.environment }
		let definitions = lazy(self.definitions).map { [$0.symbol: $0.value] }
		return dependencies
			.concat(definitions)
			.reduce(Environment(), combine: +)
	}

	public var context: Context {
		let dependencies = lazy(self.dependencies).map { $0.context }
		let definitions = lazy(self.definitions).map { [$0.symbol: $0.type] }
		return dependencies
			.concat(definitions)
			.reduce(Context(), combine: +)
	}
}
