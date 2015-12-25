//  Copyright © 2015 Rob Rix. All rights reserved.

public enum Scoping<Syntax, Term> {
	case Variable(Name)
	case Abstraction(Name, Term)
	case Identity(Syntax)


	// MARK: Equatable

	public static func equal(syntaxEqual syntaxEqual: (Syntax, Syntax) -> Bool, termEqual: (Term, Term) -> Bool)(_ left: Scoping, _ right: Scoping) -> Bool {
		switch (left, right) {
		case let (.Variable(name1), .Variable(name2)):
			return name1 == name2
		case let (.Abstraction(name1, scope1), .Abstraction(name2, scope2)):
			return name1 == name2 && termEqual(scope1, scope2)
		case let (.Identity(syntax1), .Identity(syntax2)):
			return syntaxEqual(syntax1, syntax2)
		default:
			return false
		}
	}
}


public func == <Syntax: Equatable, Term: Equatable> (left: Scoping<Syntax, Term>, right: Scoping<Syntax, Term>) -> Bool {
	return Scoping.equal(syntaxEqual: ==, termEqual: ==)(left, right)
}
