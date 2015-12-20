//  Copyright © 2015 Rob Rix. All rights reserved.

extension Module {
	public static var prelude: Module {
		let identity = Declaration("identity",
			type: nil => { A in A --> A },
			value: nil => { A in A => id })

		let constant = Declaration("constant",
			type: (nil, nil) => { A, B in A --> B --> A },
			value: (nil, nil) => { A, B in A => { B => const($0) } })

		let flip = Declaration("flip",
			type: (nil, nil, nil) => { A, B, C in (A --> B --> C) --> (B --> A --> C) },
			value: (nil, nil, nil) => { A, B, C in (A --> B --> C) => { f in (nil, nil) => { b, a in f[a, b] } } })

		return Module("Prelude", [ identity, constant, flip ])
	}
}


import Prelude
