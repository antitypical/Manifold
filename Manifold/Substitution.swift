//  Copyright (c) 2015 Rob Rix. All rights reserved.

public enum Substitution {
	case Idempotent([Variable: Type])
	case Error
}
