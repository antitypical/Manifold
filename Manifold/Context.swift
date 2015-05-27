//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias Type = Value

public typealias Context = [Name: Type]

public func lookup<A: Hashable, B>(dictionary: [A: B], key: A) -> B? {
	return dictionary[key]
}
