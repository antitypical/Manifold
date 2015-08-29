//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: TermType {
	func substitute(i: Int, _ expression: Expression) -> Expression {
		return cata { t in
			Recur(t.analysis(
				ifVariable: {
					$0.analysis(
						ifGlobal: const(t),
						ifLocal: { $0 == i ? expression : t })
				},
				ifApplication: Expression.Application,
				ifLambda: Expression.Lambda,
				ifProjection: Expression.Projection,
				ifProduct: Expression.Product,
				ifAnnotation: Expression.Annotation,
				otherwise: const(t)))
		} (Recur(self)).out
	}
}


import Prelude
