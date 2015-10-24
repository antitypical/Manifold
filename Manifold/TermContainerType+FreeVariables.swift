//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermContainerType {
	// MARK: Variables

	public var maxBoundVariable: Int {
		return cata {
			$0.analysis(
				ifType: const(-1),
				ifVariable: const(-1),
				ifApplication: max,
				ifLambda: { $0 < 0 ? max($1, $2) : max($0, $1) })
		}
	}

	public var freeVariables: Set<Int> {
		return cata {
			$0.analysis(
				ifType: const(Set()),
				ifVariable: { $0.analysis(ifGlobal: const(Set()), ifLocal: { [ $0 ] }) },
				ifApplication: uncurry(Set.union),
				ifLambda: { $1.union($2.subtract([ $0 ])) })
		}
	}
}


import Prelude
