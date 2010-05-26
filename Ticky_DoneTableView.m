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

- (void) keyDown:(NSEvent *) event
{
	int row = [self selectedRow];
		
    switch ([event keyCode])
    {
		case 49: // Space bar
			[[NSApp delegate] markSelectedAsDone:self];
			break;

        case 126: // Up
            if (row == 0){
				[self deselectAll:nil];
				NSIndexSet * selSet = [NSIndexSet indexSetWithIndex:[[[NSApp delegate] tableView] numberOfRows]-1];
				[[[NSApp delegate] tableView] selectRowIndexes:selSet byExtendingSelection:NO];
				[[[NSApp delegate] window] makeFirstResponder:[[NSApp delegate] tableView]];
			}
			else {
				row -= 1;
				NSIndexSet *selSet = [NSIndexSet indexSetWithIndex:row];
				[self selectRowIndexes:selSet byExtendingSelection:NO];
			}
			
			break;
			
		case 125: // Down
			if (row == [self numberOfRows]-1) {
				[self deselectAll:nil];
				NSIndexSet * selSet = [NSIndexSet indexSetWithIndex:0];
				[[[NSApp delegate] tableView] selectRowIndexes:selSet byExtendingSelection:NO];
				[[[NSApp delegate] window] makeFirstResponder:[[NSApp delegate] tableView]];
			}
			else {
				row += 1;
				NSIndexSet *selSet = [NSIndexSet indexSetWithIndex:row];
				[self selectRowIndexes:selSet byExtendingSelection:NO];				
			}
			
			break;
			
		default:
			[super keyDown:event];
			return;
	}
}

@end
