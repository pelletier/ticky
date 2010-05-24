// 
//  Task.m
//  Ticky
//
//  Created by Thomas PELLETIER on 25/04/10.
//  Copyright 2010 Thomas PELLETIER. All rights reserved.
//

#import "Task.h"


@implementation Task 

@dynamic Content;
@dynamic Done;
@dynamic Order;

- (NSString*) identifier {
	return [[[self objectID] URIRepresentation] absoluteString];
}

@end
