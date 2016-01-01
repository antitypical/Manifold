//  Copyright © 2015 Rob Rix. All rights reserved.

extension TermContainerType {
	public var debugDescription: String {
		return cata { $0.debugDescription }
	}
}
