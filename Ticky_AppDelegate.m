//
//  Ticky_AppDelegate.m
//  Ticky
//
//  Created by Thomas PELLETIER on 13/04/10.
//  Copyright Thomas PELLETIER 2010 . All rights reserved.
//

#import "Ticky_AppDelegate.h"


@implementation Ticky_AppDelegate

@synthesize window;
@synthesize addTaskPanel;
@synthesize tableView;
@synthesize doneTableView;
@synthesize tasksController;
@synthesize doneTasksController;
@synthesize doneTableDelegate;


#pragma mark -
#pragma mark Initialize and desktroy

- (void)awakeFromNib {
	/* Add notification event for task changes (in order to refresh the badge for example) */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:[self managedObjectContext]];
	[tasksController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
	
	/* Configure the todo list */
	[tableView setDataSource:self];
	[tableView registerForDraggedTypes:[NSArray arrayWithObject:PrivateTableViewDataType]];
	
	/* Configure the done list */
	[doneTableView setDataSource:doneTableDelegate];
	[doneTableView registerForDraggedTypes:[NSArray arrayWithObject:PrivateTableViewDataType]];
}

- (void)dealloc {
	/* Release them all */
	[_sortDescriptors release];
    [window release];
	[addTaskPanel release];
	[tableView release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
	/* Remove events */
	[tasksController removeObserver:self forKeyPath:@"arrangedObjects"];
	
	/* Final dealloc */
    [super dealloc];
}


#pragma mark -
#pragma mark TableView drag and drop

- (NSArray *)itemsUsingFetchPredicate:(NSPredicate *)fetchPredicate
{
	NSError *error = nil;
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[self managedObjectContext]];
	
	NSArray *arrayOfItems;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDesc];
	[fetchRequest setPredicate:fetchPredicate];
	[fetchRequest setSortDescriptors:[self sortDescriptors]];
	arrayOfItems = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	return arrayOfItems;
}

- (NSArray *)itemsWithViewPosition:(int)value
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"Order == %i", value];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (NSArray *)itemsWithNonTemporaryViewPosition
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"Order >= 0"];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (NSArray *)itemsWithViewPositionGreaterThanOrEqualTo:(int)value
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"Order >= %i", value];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (NSArray *)itemsWithViewPositionBetween:(int)lowValue and:(int)highValue
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"Order >= %i && Order <= %i", lowValue, highValue];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (int)renumberViewPositionsOfItems:(NSArray *)array startingAt:(int)value
{
	int currentViewPosition = value;
	
	int count = 0;
	
	if( array && ([array count] > 0) )
	{
		for( count = 0; count < [array count]; count++ )
		{
			NSManagedObject *currentObject = [array objectAtIndex:count];
			[currentObject setValue:[NSNumber numberWithInt:currentViewPosition] forKey:@"Order"];
			currentViewPosition++;
		}
	}
	
	return currentViewPosition;
}

- (void)renumberViewPositions {
	NSLog(@"Start renumbering");
	NSArray *startItems = [self itemsWithViewPosition:[startViewPositionNum intValue]];
	
	NSArray *existingItems = [self itemsWithNonTemporaryViewPosition];
	
	NSArray *endItems = [self itemsWithViewPosition:[endViewPositionNum intValue]];
	
	int currentViewPosition = 0;
	
	if( startItems && ([startItems count] > 0) )
		currentViewPosition = [self renumberViewPositionsOfItems:startItems startingAt:currentViewPosition];
	
	if( existingItems && ([existingItems count] > 0) )
		currentViewPosition = [self renumberViewPositionsOfItems:existingItems startingAt:currentViewPosition];
	
	if( endItems && ([endItems count] > 0) )
		currentViewPosition = [self renumberViewPositionsOfItems:endItems startingAt:currentViewPosition];
}

- (NSArray *)sortDescriptors
{
	if( _sortDescriptors == nil )
	{
		NSSortDescriptor *order_by_status = [[NSSortDescriptor alloc] initWithKey:@"Done" ascending:YES];
		NSSortDescriptor *order_by_order = [[NSSortDescriptor alloc] initWithKey:@"Order" ascending:YES];
		_sortDescriptors = [NSArray arrayWithObjects:order_by_status, order_by_order, nil];
		[order_by_order release];
		[order_by_status release];
	}
	return _sortDescriptors;
}


- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pasteboard
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	[pasteboard declareTypes:[NSArray arrayWithObject:PrivateTableViewDataType] owner:self];
	[pasteboard setData:data forType:PrivateTableViewDataType];
	return YES;
}


- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id  <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	if( [info draggingSource] == tableView )
	{
		if( operation == NSTableViewDropOn )
			[tv setDropRow:row dropOperation:NSTableViewDropAbove];
		
		return NSDragOperationMove;
	}
	else
	{
		return NSDragOperationNone;
	}
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
	NSPasteboard *pasteboard = [info draggingPasteboard];
	NSData *rowData = [pasteboard dataForType:PrivateTableViewDataType];
	NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	
	NSArray *allItemsArray = [tasksController arrangedObjects];
	NSMutableArray *draggedItemsArray = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
	
	NSUInteger currentItemIndex = 0;
	NSRange range = NSMakeRange( 0, [rowIndexes lastIndex] + 1 );
	while([rowIndexes getIndexes:&currentItemIndex maxCount:1 inIndexRange:&range] > 0)
	{
		NSManagedObject *thisItem = [allItemsArray objectAtIndex:currentItemIndex];
		[draggedItemsArray addObject:thisItem];
	}
	
	int count;
	for( count = 0; count < [draggedItemsArray count]; count++ )
	{
		NSManagedObject *currentItemToMove = [draggedItemsArray objectAtIndex:count];
		[currentItemToMove setValue:temporaryViewPositionNum forKey:@"Order"];
	}
	
	int tempRow;
	if( row == 0 )
		tempRow = -1;
	else
		tempRow = row - 1; // nasty fix. should be tempRow = row here
	
	NSArray *startItemsArray = [self itemsWithViewPositionBetween:0 and:tempRow];
	NSArray *endItemsArray = [self itemsWithViewPositionGreaterThanOrEqualTo:row];
	
	int currentViewPosition;
	
	currentViewPosition = [self renumberViewPositionsOfItems:startItemsArray startingAt:0];
	
	currentViewPosition = [self renumberViewPositionsOfItems:draggedItemsArray startingAt:currentViewPosition];
	
	currentViewPosition = [self renumberViewPositionsOfItems:endItemsArray startingAt:currentViewPosition];
	
	return YES;
}


#pragma mark -
#pragma mark Events callbacks


/*
 * Remove the table selected task
 */
- (IBAction)removeSelectedTasks:(id)sender {
	NSArray *selectedItems = [tasksController selectedObjects];
	
	int count;
	for( count = 0; count < [selectedItems count]; count ++ )
	{
		NSManagedObject *currentObject = [selectedItems objectAtIndex:count];
		[[self managedObjectContext] deleteObject:currentObject];
	}
	[self renumberViewPositions];
}


/*
 * Observe changes on tasksController
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	[self updateBadge];
}


/*
 * Be sure tasksController is always synchronized with Core Data
 */
- (void)objectsDidChange:(NSNotification *)note {
	[tasksController rearrangeObjects];
}


/*
 * Open the Feedback page
 */
- (void)openFeedback:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://feedback.ticky.im/"]];
}

/*
 * Handle the Cmd+N new task event
 */
- (IBAction)addNewTask:(id)sender {
	[addTaskPanel makeKeyAndOrderFront:self];
}


/*
 * Handle the Cmd+D mark current task as done event
 */
- (IBAction)markSelectedAsDone:(id)sender {
	NSLog(@"%@",[[[[self tasksController] selectedObjects] lastObject] objectID]);
	NSManagedObject *mo = [[self managedObjectContext] objectWithID:[[[[self tasksController] selectedObjects] lastObject] objectID]];
	
	NSNumber *current = [mo valueForKey:@"Done"];
	
	if (current == nil) {
		[mo setValue:[NSNumber numberWithInt:1] forKey:@"Done"];
	}
	else {
		if ([current isEqualToNumber:[NSNumber numberWithInt:0]]) {
			[mo setValue:[NSNumber numberWithInt:1] forKey:@"Done"];
		}
		else {
			[mo setValue:[NSNumber numberWithInt:0] forKey:@"Done"];
		}

	}
	
	NSIndexSet * selSet = [NSIndexSet indexSetWithIndex:0];
	[tableView selectRowIndexes:selSet byExtendingSelection:NO];
}

/*
 * Handle the "filter-on-type" event.
 */
- (IBAction) filterTasks:(id)sender {
	NSMutableString *searchText = [NSMutableString stringWithString:[searchField stringValue]];
	
	// Remove extraenous whitespace
	while ([searchText rangeOfString:@"Â  "].location != NSNotFound) {
		[searchText replaceOccurrencesOfString:@"Â  " withString:@" " options:0 range:NSMakeRange(0, [searchText length])];
	}
	
	//Remove leading space
	if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0,1)];
	
	//Remove trailing space
	if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange([searchText length]-1, 1)];
	
	if ([searchText length] == 0) {
		[tasksController setFilterPredicate:nil];
		return;
	}
	
	NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];
	
	if ([searchTerms count] == 1) {
		NSPredicate *p = [NSPredicate predicateWithFormat:@"(Content contains[cd] %@)", searchText];
		[tasksController setFilterPredicate:p];
	} else {
		NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
		for (NSString *term in searchTerms) {
			NSPredicate *p = [NSPredicate predicateWithFormat:@"(Content contains[cd] %@)", term];
			[subPredicates addObject:p];
		}
		NSPredicate *cp = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
		
		[tasksController setFilterPredicate:cp];
		[subPredicates release];
	}
}


#pragma mark -
#pragma mark Subclassed methods


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
					hasVisibleWindows:(BOOL)flag
{
	if( !flag )
		[window makeKeyAndOrderFront:nil];
	
	return YES;
}

- (id)updateBadge {
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"(Done != YES)"];
	[request setPredicate:bPredicate];
	
	NSError *error;
	NSArray *filtered = [managedObjectContext executeFetchRequest:request error:&error];
	
	int nbr = [filtered count];
	
	NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
	[tile setBadgeLabel:[NSString stringWithFormat:@"%d", nbr]];
	return self;
}




#pragma mark -
#pragma mark Core Data implementation

/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "Ticky" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Ticky"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
	/* This option is for Core Data versioning and migration */
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
	
	
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:dict 
                                                error:&error]){
		
		/* Let's display a nicer alert box to the end user (with more informations and what to do) */
		NSDictionary *ui = [error userInfo];
		if (ui) {
			NSLog(@"%@:%s %@", [self class], _cmd, [error localizedDescription]);
			for (NSError *suberror in [ui valueForKey:NSDetailedErrorsKey]) {
				NSLog(@"\t%@", [suberror localizedDescription]);
			}
		}
		else {
			NSLog(@"%@:%s %@", [self class], _cmd, [error localizedDescription]);
		}
		
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert setMessageText:@"Unable to load the tasks database."];
		NSString *msgText = nil;
		msgText = [NSString stringWithFormat:@"The recipes database %@%@%@\n%@",
				   @"is either corrupt or was created by a newer ",
				   @"version of Ticky. Please contact support to assist ",
				   @"with this error.\n\nError: ",
				   [error localizedDescription]];
		[alert setInformativeText:msgText];
		[alert addButtonWithTitle:@"Quit"];
		[alert runModal];
		[alert dealloc];
		
		/* And finally force the program to exit (with error code) */
		exit(1);
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}

@end
