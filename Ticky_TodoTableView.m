//
//  Ticky_TodoTableView.m
//  Ticky
//
//  Created by Thomas PELLETIER on 26/05/10.
//  Copyright 2010 Thomas PELLETIER. All rights reserved.
//

#import "Ticky_TodoTableView.h"


@implementation Ticky_TodoTableView

- (BOOL)becomeFirstResponder {
	[[[NSApp delegate] doneTableView] deselectAll:self];
	return YES;
}

@end
