//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	func substitute(i: Int, _ expression: Self) -> Self {
		return Self.cata { (t: Expression<Self>) in
			t.analysis(
				ifVariable: {
					$0.analysis(
						ifGlobal: const(Self(t)),
						ifLocal: { $0 == i ? expression : Self(t) })
				},
				ifApplication: Self.Application,
				ifLambda: Self.Lambda,
				ifProjection: Self.Projection,
				ifProduct: Self.Product,
				ifIf: Self.If,
				ifAnnotation: Self.Annotation,
				otherwise: const(Self(t)))
		} (self)
	}
}


import Prelude
