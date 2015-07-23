//  Copyright © 2015 Rob Rix. All rights reserved.

extension Expression where Recur: FixpointType {
	public static var description: Module<Recur> {
		return Module([ list, tag ], [
		])
	}
}


import Prelude
