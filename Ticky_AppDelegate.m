//
//  Ticky_AppDelegate.m
//  Ticky
//
//  Created by Thomas PELLETIER on 13/04/10.
//  Copyright __MyCompanyName__ 2010 . All rights reserved.
//

#import "Ticky_AppDelegate.h"

@implementation Ticky_AppDelegate

@synthesize window;
@synthesize addTaskPanel;
@synthesize tableView;
@synthesize tasksController;


#pragma mark -
#pragma mark Initialize and desktroy

- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:[self managedObjectContext]];
	[tasksController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
}


- (void)dealloc {
	
    [window release];
	[addTaskPanel release];
	[tableView release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	[tasksController removeObserver:self forKeyPath:@"arrangedObjects"];
    [super dealloc];
}



#pragma mark -
#pragma mark Events callbacks


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
- (void)objectsDidChange:(NSNotification *)note
{
	[tasksController rearrangeObjects];
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
	[mo setValue:[NSNumber numberWithInt:1] forKey:@"Done"];
	
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

- (void)updateBadge {
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
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
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
