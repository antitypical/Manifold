//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Error: Printable {
	public init(reason: String) {
		self = Leaf(reason)
	}


	case Leaf(String)
	case Branch([Error])


	// MARK: Printable

	public var description: String {
		switch self {
		case let Leaf(reason):
			return reason
		case let Branch(errors):
			return join("\n", lazy(errors).map(toString))
		}
	}
}
