//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Description: CustomDebugStringConvertible, DictionaryLiteralConvertible, TermType {
	public init(branches: [(String, Description)]) {
		switch branches.count {
		case 0:
			self = .End
		case 1:
			self = branches[0].1
		default:
			self = .Argument(.BooleanType, {
				.If($0,
					branches[0].1,
					Description(branches: Array(branches.dropFirst())))
			})
		}
	}


	public func type(recur: Expression<Description>) -> Expression<Description> {
		switch self {
		case .End:
			return .UnitType
		case let .Pure(a):
			return a()
		case .Recursive:
			return recur
		case let .Argument(x, continuation):
			return .lambda(x, continuation)
		}
	}


	public func value(recur: Expression<Description>) -> Expression<Description> {
		switch self {
		case .End:
			return .Unit
		case let .Pure(a):
			return a()
		case .Recursive:
			return recur
		case let .Argument(x, continuation):
			return .lambda(x, continuation)
		}
	}


	// MARK: CustomDebugStringConvertible

	public var debugDescription: String {
		switch self {
		case .End:
			return ".End"
		case let .Pure(f):
			return ".Pure(\(String(reflecting: f())))"
		case .Recursive:
			return ".Recursive"
		case let .Argument(a, f):
			return ".Argument(\(String(reflecting: a)), \(String(reflecting: f(.Variable(.Local(0))))))"
		}
	}


	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (String, Description)...) {
		self.init(branches: elements)
	}


	// MARK: TermType

	public init(_ expression: () -> Expression<Description>) {
		self = .Pure(expression)
	}

	public var out: Expression<Description> {
		switch self {
		case .End:
			return .UnitType
		case let .Pure(a):
			return a()
		case .Recursive:
			return .lambda(.Type, { Description(self.type($0.out)) })
		case let .Argument(x, continuation):
			return .lambda(x, continuation)
		}
	}


	// MARK: Cases

	case End
	case Pure(() -> Expression<Description>)
	case Recursive
	indirect case Argument(Description, Description -> Description)
}


import Prelude
