//
//  Ticky_DoneTableDelegate.m
//  Ticky
//
//  Created by Thomas PELLETIER on 26/05/10.
//  Copyright 2010 Thomas PELLETIER. All rights reserved.
//

#import "Ticky_DoneTableDelegate.h"

@implementation Ticky_DoneTableDelegate

@synthesize tableView;
@synthesize tasksController;

/*
 * Initiate a drag from the table
 */

- (BOOL)tableView:(NSTableView*)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
	NSLog(@"Begin Drag done list");
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	[pboard declareTypes:[NSArray arrayWithObject:PrivateTableViewDataType] owner:self];
	[pboard setData:data forType:PrivateTableViewDataType];
	return YES;
}


/*
 * Validate a drop operation
 */

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
	NSLog(@"Validate drop");
	if([info draggingSource] == tableView) {
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

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
	NSLog(@"Accept drops");
	
	/* Extract data */
	NSPasteboard *pboard = [info draggingPasteboard];
	NSData *rowData = [pboard dataForType:PrivateTableViewDataType];
	NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];

	/* List of the total tasks in the tableview */
	NSArray *allItemsArray = [tasksController arrangedObjects];
	
	/* Create an empty array wich will contain the moved tasks */
	NSMutableArray *draggedItemsArray = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
	
	/* Simple item counter */
	NSUInteger currentItemIndex = 0;
	
	/* Create a range based on moved rows */
	NSRange range = NSMakeRange( 0, [rowIndexes lastIndex] + 1 );
	
	/* For each moved row */
	while([rowIndexes getIndexes:&currentItemIndex maxCount:1 inIndexRange:&range] > 0) {
		/* Get the corresponding CoreData object */
		NSManagedObject *thisItem = [allItemsArray objectAtIndex:currentItemIndex];
		/* Add it to the dragged items list */
		[draggedItemsArray addObject:thisItem];
	}
	
	int count;
	/* Add a tempoary order number to the moved items */
	for( count = 0; count < [draggedItemsArray count]; count++ ) {
		NSManagedObject *currentItemToMove = [draggedItemsArray objectAtIndex:count];
		[currentItemToMove setValue:temporaryViewPositionNum forKey:@"Order"];
	}
	
	return YES;
}

@end
