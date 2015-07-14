//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Binding<Recur> {
	public init(_ symbol: Name, _ value: Expression<Recur>, _ type: Expression<Recur>) {
		self.symbol = symbol
		self.value = value
		self.type = type
	}

	public let symbol: Name
	public let value: Expression<Recur>
	public let type: Expression<Recur>
}
