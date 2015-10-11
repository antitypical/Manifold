//  Copyright © 2015 Rob Rix. All rights reserved.

/// Like >>- when you don’t care about the extracted value.
func >> <L, R1, R2> (left: Either<L, R1>, @autoclosure right: () -> Either<L, R2>) -> Either<L, R2> {
	return left >>- { _ in right() }
}


import Either
