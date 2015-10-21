//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermContainerType {
	// MARK: Variables

	public var maxBoundVariable: Int {
		return cata {
			$0.analysis(
				ifApplication: max,
				ifLambda: { $0 < 0 ? max($1, $2) : max($0, $1) },
				ifProjection: { $0.0 },
				ifProduct: max,
				ifIf: { max($0, $1, $2) },
				ifAnnotation: max,
				otherwise: const(-1))
		}
	}

	public var freeVariables: Set<Int> {
		return cata {
			$0.analysis(
				ifVariable: { $0.analysis(ifGlobal: const(Set()), ifLocal: { [ $0 ] }) },
				ifApplication: uncurry(Set.union),
				ifLambda: { $1.union($2.subtract([ $0 ])) },
				ifProjection: { $0.0 },
				ifProduct: uncurry(Set.union),
				ifIf: { $0.union($1).union($2) },
				ifAnnotation: uncurry(Set.union),
				otherwise: const(Set()))
		}
	}
}


import Prelude
