//  Copyright (c) 2015 Rob Rix. All rights reserved.

func find<C: CollectionType>(collection: C, predicate: C.Generator.Element -> Bool) -> C.Index? {
	for (index, each) in zip(indices(collection), collection) {
		if predicate(each) { return index }
	}
	return nil
}
