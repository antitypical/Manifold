//  Copyright © 2015 Rob Rix. All rights reserved.

public enum TypeConstructor<Recur: TermType> {
	case Argument(Recur, Recur -> TypeConstructor)
	case End(Datatype<Recur>)
}