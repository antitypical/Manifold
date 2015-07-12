//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Module<Recur> {
	public typealias Binding = Expression<Recur>.Definition
	public typealias Environment = Expression<Recur>.Environment
	public typealias Context = Expression<Recur>.Context

	public init<D: SequenceType, S: SequenceType where D.Generator.Element == Module, S.Generator.Element == Binding>(_ dependencies: D, _ definitions: S) {
		self.dependencies = Array(dependencies)
		self.definitions = Array(definitions)
	}

	public init<D: SequenceType where D.Generator.Element == Module>(_ dependencies: D, _ definitions: Binding...) {
		self.init(dependencies, definitions)
	}

	public init(_ definitions: Binding...) {
		self.init([], definitions)
	}

	public let dependencies: [Module]
	public let definitions: [Binding]

	public var environment: Environment {
		let dependencies = lazy(self.dependencies).map { $0.environment }
		let definitions = lazy(self.definitions).map { [$0.0: $0.1] }
		return dependencies
			.concat(definitions)
			.reduce(Environment(), combine: +)
	}

	public var context: Context {
		let dependencies = lazy(self.dependencies).map { $0.context }
		let definitions = lazy(self.definitions).map { [$0.0: $0.2] }
		return dependencies
			.concat(definitions)
			.reduce(Context(), combine: +)
	}
}
