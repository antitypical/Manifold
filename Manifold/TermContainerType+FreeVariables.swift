//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermContainerType {
	// MARK: Variables

	public var maxBoundVariable: Int {
		return cata {
			$0.analysis(
				ifApplication: max,
				ifLambda: { $0 < 0 ? max($1, $2) : max($0, $1) },
				ifIf: { max($0, $1, $2) },
				otherwise: const(-1))
		}
	}

	public var freeVariables: Set<Int> {
		return cata {
			$0.analysis(
				ifVariable: { $0.analysis(ifGlobal: const(Set()), ifLocal: { [ $0 ] }) },
				ifApplication: uncurry(Set.union),
				ifLambda: { $1.union($2.subtract([ $0 ])) },
				ifIf: { $0.union($1).union($2) },
				otherwise: const(Set()))
		}
	}
}


import Prelude
