//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias Type = Value

public typealias Context = [(Name, Type)]

public func lookup<A: Equatable, B, S: SequenceType where S.Generator.Element == (A, B)>(sequence: S, key: A) -> B? {
	for (k, v) in sequence {
		if k == key { return v }
	}
	return nil
}
