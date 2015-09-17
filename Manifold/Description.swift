//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Description: CustomDebugStringConvertible, DictionaryLiteralConvertible, TermType {
	public init(branches: [(String, Description)]) {
		switch branches.count {
		case 0:
			self = .End
		case 1:
			self = branches[0].1
		default:
			let tagType: Description = .BooleanType
			self = .Argument(tagType, { tag in
				.If(tag,
					branches[0].1,
					Description(branches: Array(branches.dropFirst())))
			})
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

	func out(recur: Description) -> Expression<Description> {
		switch self {
		case .End:
			return Expression.UnitType
		case let .Pure(a):
			return a()
		case .Recursive:
			return recur.out(recur)
		case let .Argument(x, continuation):
			return .lambda(x, continuation)
		}
	}

	public var out: Expression<Description> {
		return .lambda(.Type, out >>> Description.init)
	}


	// MARK: Cases

	case End
	indirect case Pure(() -> Expression<Description>)
	case Recursive
	indirect case Argument(Description, Description -> Description)
}


import Prelude
