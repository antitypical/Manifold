//  Copyright © 2015 Rob Rix. All rights reserved.

public struct Binding<Recur> {
	public init(_ name: String, _ value: Expression<Recur>, _ type: Expression<Recur>) {
		self.name = name
		self.value = value
		self.type = type
	}

	public let name: String
	public let value: Expression<Recur>
	public let type: Expression<Recur>
}
