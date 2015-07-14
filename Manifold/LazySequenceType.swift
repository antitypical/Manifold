//  Copyright © 2015 Rob Rix. All rights reserved.

public protocol LazySequenceType: SequenceType {}
extension LazySequence: LazySequenceType {}
extension LazyForwardCollection: LazySequenceType {}
extension LazyBidirectionalCollection: LazySequenceType {}
extension LazyRandomAccessCollection: LazySequenceType {}
