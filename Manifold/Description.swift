//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Description: DictionaryLiteralConvertible, TermType {
	// MARK: DictionaryLiteralConvertible

	public init(dictionaryLiteral elements: (String, Description)...) {
		switch elements.count {
		case 0:
			self = .End
		case 1:
			self = elements[0].1
		default:
			let tagType: Description = Tag.encodeTagType(elements.map { $0.0 })
			self = .Argument(tagType.out, { tag in
				Description(Expression.lambda(tagType) {
					$0
				})[Description(tag)]
			})
		}
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
			return Expression.lambda(Description(x)) { Description(continuation($0.out).out) }
		}
	}


	// MARK: Cases

	case End
	indirect case Pure(Expression<Description>)
	indirect case Recursive(Description)
	indirect case Argument(Expression<Description>, Expression<Description> -> Description)
}


import Prelude
