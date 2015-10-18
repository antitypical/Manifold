//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Elaborated<Term: TermType> {
	indirect case Unroll(Term, Expression<Elaborated>)
}