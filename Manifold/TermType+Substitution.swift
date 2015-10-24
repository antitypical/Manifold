//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermType {
	public func substitute(i: Int, _ expression: Self) -> Self {
		return cata { (t: Expression<Self>) in
			t.analysis(
				ifVariable: {
					$0.analysis(
						ifGlobal: const(Self(t)),
						ifLocal: { $0 == i ? expression : Self(t) })
				},
				ifApplication: Self.Application,
				ifLambda: Self.Lambda,
				otherwise: const(Self(t)))
		}
	}
}


import Prelude
