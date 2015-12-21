//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static let modules: [String:Module] = Dictionary([
		unit,
		boolean,
		list,
		natural,
		maybe,
		either,
		pair,
		prelude,
		propositionalEquality,
		sigma,
		vector,
		finiteSet,
		string,
	].map { ($0.name, $0) })
}
