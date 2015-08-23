//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Description: DictionaryLiteralConvertible, TermType {
	public init(branches: [(String, Description)]) {
		switch branches.count {
		case 0:
			self = .End
		case 1:
			self = branches[0].1
		default:
			let tagType: Description = Tag.encodeTagType(branches.map { $0.0 })
			self = .Argument(tagType, { tag in
				let eliminator = Description.lambda(tagType) { $0 }
				return eliminator[tag]
			})
		}
	}


	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (String, Description)...) {
		self.init(branches: elements)
	}


	// MARK: TermType

	public init(_ expression: () -> Expression<Description>) {
		self = .Pure(expression())
	}

	public var out: Expression<Description> {
		switch self {
		case .End:
			return Expression.UnitType
		case let .Pure(a):
			return a
		case let .Recursive(rest):
			return rest.out
		case let .Argument(x, continuation):
			return .lambda(x, continuation)
		}
	}


	// MARK: Cases

	case End
	indirect case Pure(Expression<Description>)
	indirect case Recursive(Description)
	indirect case Argument(Description, Description -> Description)
}


import Prelude
