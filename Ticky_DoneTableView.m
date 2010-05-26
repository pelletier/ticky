//
//  Ticky_DoneTableView.m
//  Ticky
//
//  Created by Thomas PELLETIER on 26/05/10.
//  Copyright 2010 Thomas PELLETIER. All rights reserved.
//

#import "Ticky_DoneTableView.h"


@implementation Ticky_DoneTableView

- (BOOL)becomeFirstResponder {
	[[[NSApp delegate] tableView] deselectAll:self];
	return YES;
}

@end
