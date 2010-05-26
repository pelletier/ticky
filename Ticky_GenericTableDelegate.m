//
//  Ticky_GenericTableDelegate.m
//  Ticky
//
//  Created by Thomas PELLETIER on 26/05/10.
//  Copyright 2010 Thomas PELLETIER. All rights reserved.
//

#import "Ticky_GenericTableDelegate.h"

@implementation Ticky_GenericTableDelegate

@synthesize tableView;
@synthesize tasksController;
@synthesize otherTasksController;


/*
 * Initiate a drag from the table
 */

- (BOOL)tableView:(NSTableView*)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	[pboard declareTypes:[NSArray arrayWithObject:PrivateTableViewDataType] owner:self];
	[pboard setData:data forType:PrivateTableViewDataType];
	return YES;
}


/*
 * Validate a drop operation
 */

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
	
	NSArray *tvlist = [[NSApp delegate] tableViews];
	if([tvlist containsObject:[info draggingSource]]) {
		if(op == NSTableViewDropOn) {
			[tv setDropRow:row dropOperation:NSTableViewDropAbove];
		}
		return NSDragOperationMove;
	}
	else {
		return NSDragOperationNone;
	}
}


/*
 * Accept drops
 */

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{   // Note for dummies: the <row> argument is the position of the drop row!
	
	/* Extract data */
	NSPasteboard *pasteboard = [info draggingPasteboard];
	NSData *rowData = [pasteboard dataForType:PrivateTableViewDataType];
	NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	
	/* Make a copy of the actual tasks array */
	NSMutableArray *tasksArrayCopy = [NSMutableArray arrayWithArray:[tasksController arrangedObjects]];
	
	if ([info draggingSource] == tableView) {
		
		/* Construct an array containg the moved rows */
		NSMutableArray *draggedItemsArray = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
		NSRange range = NSMakeRange( 0, [rowIndexes lastIndex] + 1 );
		NSUInteger currentItemIndex = 0;
		
		while([rowIndexes getIndexes:&currentItemIndex maxCount:1 inIndexRange:&range] > 0)
		{	/* For each moved index */
			NSManagedObject *thisItem = [tasksArrayCopy objectAtIndex:currentItemIndex];
			[draggedItemsArray addObject:thisItem];
			[tasksArrayCopy removeObjectAtIndex:currentItemIndex];
			/* Let's put a NULL placeholder here */
			[tasksArrayCopy insertObject:[NSNull null] atIndex:currentItemIndex];
		}
		
		/* For each moved task */
		for (id object in draggedItemsArray) {
			[tasksArrayCopy insertObject:object atIndex:row];
		}
		
		/* Remove NULL placeholders */
		[tasksArrayCopy removeObject:[NSNull null]];
		
		/* Re number */
		int num = 0;
		for (id object in tasksArrayCopy) {
			[object setValue:[NSNumber numberWithInt:num] forKey:@"Order"];
			num += 1;
		}
		
		/* Done */
		return YES;
	}
	/* This drop comes from the other table view */
	else {
		/* First, make a copy of the source tasks list */
		NSMutableArray *sourceTasksListCopy = [NSMutableArray arrayWithArray:[otherTasksController arrangedObjects]];
		
		/* Construct an array containg the moved rows */
		NSMutableArray *draggedItemsArray = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
		NSRange range = NSMakeRange( 0, [rowIndexes lastIndex] + 1 );
		NSUInteger currentItemIndex = 0;
		
		while([rowIndexes getIndexes:&currentItemIndex maxCount:1 inIndexRange:&range] > 0)
		{	/* For each moved index */
			NSManagedObject *thisItem = [sourceTasksListCopy objectAtIndex:currentItemIndex];
			int newDoneStatus = 0;
			if ([[thisItem valueForKey:@"Done"] isEqualToNumber:[NSNumber numberWithInt:0]]) { newDoneStatus = 1; }
			[sourceTasksListCopy removeObjectAtIndex:currentItemIndex];
			NSLog(@"%@ switched from %d to %d", [thisItem valueForKey:@"Content"], [thisItem valueForKey:@"Done"], newDoneStatus);
			[thisItem setValue:[NSNumber numberWithInt:newDoneStatus] forKey:@"Done"];
			[draggedItemsArray addObject:thisItem];
		}
		
		/* For each moved task */
		for (id object in draggedItemsArray) {
			[tasksArrayCopy insertObject:object atIndex:row];
		}
		
		/* Re number target list */
		int num = 0;
		for (id object in sourceTasksListCopy) {
			[object setValue:[NSNumber numberWithInt:num] forKey:@"Order"];
			num += 1;
		}
		
		/* Re number source list */
		num = 0;
		for (id object in tasksArrayCopy) {
			[object setValue:[NSNumber numberWithInt:num] forKey:@"Order"];
			num += 1;
		}
		
		return YES;
	}

}

@end
