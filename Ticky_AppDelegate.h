//
//  Ticky_AppDelegate.h
//  Ticky
//
//  Created by Thomas PELLETIER on 13/04/10.
//  Copyright Thomas PELLETIER 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Ticky_AddTaskPanel.h"
#import "Ticky_Globals.h"

@interface Ticky_AppDelegate : NSObject 
{
    NSWindow *window;
    Ticky_AddTaskPanel *addTaskPanel;
	
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	NSArray *_sortDescriptors;
	
	IBOutlet NSArrayController *tasksController;
	IBOutlet NSSearchField *searchField;
	IBOutlet NSTableView *tableView;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet Ticky_AddTaskPanel *addTaskPanel;
@property (nonatomic, retain) IBOutlet NSTableView *tableView;
@property (nonatomic, retain) IBOutlet NSArrayController *tasksController;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

//@property (nonatomic, retain, readonly) NSArray *sortDescriptors;

- (IBAction)saveAction:sender;
- (IBAction)filterTasks:(id)sender;
- (IBAction)addNewTask:(id)sender;
- (IBAction)removeSelectedTasks:(id)sender;
- (IBAction)markSelectedAsDone:(id)sender;
- (IBAction)openFeedback:(id)sender;

- (id)updateBadge;


/* Drag and Drop / Reordering helpers */
- (NSArray *)itemsUsingFetchPredicate:(NSPredicate *)fetchPredicate;
- (NSArray *)itemsWithViewPosition:(int)value;
- (NSArray *)itemsWithNonTemporaryViewPosition;
- (NSArray *)itemsWithViewPositionGreaterThanOrEqualTo:(int)value;
- (NSArray *)itemsWithViewPositionBetween:(int)lowValue and:(int)highValue;
- (int)renumberViewPositionsOfItems:(NSArray *)array startingAt:(int)value;
- (void)renumberViewPositions;

- (NSArray *)sortDescriptors;

@end
