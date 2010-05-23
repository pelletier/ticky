//
//  Ticky_TableController.m
//  Ticky
//
//  Created by Thomas PELLETIER on 13/04/10.
//  Copyright 2010 Thomas PELLETIER. All rights reserved.
//

#import "Ticky_ArrayController.h"


@implementation Ticky_ArrayController

- (void)awakeFromNib {
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Done" ascending:YES];
	[tasksController setSortDescriptors:[NSArray arrayWithObject:descriptor]];
	[descriptor release];	
}

- (void) dealloc{
	[tasksController release];
	[super dealloc];
}

@end