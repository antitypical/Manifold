//  Copyright © 2015 Rob Rix. All rights reserved.

enum ABT<Applied, Recur> {
	case Variable(Name)
	case Abstraction(Name, Recur)
	case Constructor(Applied)
}

enum AST<Recur> {
	case Lambda(Recur)
	case Application(Recur, Recur)
}
