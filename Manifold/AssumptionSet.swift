//  Copyright (c) 2015 Rob Rix. All rights reserved.

public typealias AssumptionSet = [Int: [Scheme]]


public func + (left: AssumptionSet, right: AssumptionSet) -> AssumptionSet {
	var result = left
	for (variable, schemes) in right {
		result[variable] = result[variable] ?? [] + schemes
	}
	return result
}
