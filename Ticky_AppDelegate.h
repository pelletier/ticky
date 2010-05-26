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
#import "Ticky_GenericTableDelegate.h"


@interface Ticky_AppDelegate : NSObject 
{
	/* Internal data */
	NSArray *_sortDescriptors;
	
	/* Core Data business */
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	
	
	/* GUI elements */
	NSWindow *window;
    Ticky_AddTaskPanel *addTaskPanel;
	IBOutlet NSSearchField *searchField;
	IBOutlet NSTableView *tableView;
	IBOutlet NSTableView *doneTableView;
	
	/* IB Controllers outlets*/
	IBOutlet NSArrayController *tasksController;
	IBOutlet NSArrayController *doneTasksController;
	
	/* Delegates */
	IBOutlet Ticky_GenericTableDelegate *todoTableDelegate;
	IBOutlet Ticky_GenericTableDelegate *doneTableDelegate;
}

/* Delegates */
@property (nonatomic, retain) IBOutlet Ticky_GenericTableDelegate *todoTableDelegate;
@property (nonatomic, retain) IBOutlet Ticky_GenericTableDelegate *doneTableDelegate;

/* GUI elements */
@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet Ticky_AddTaskPanel *addTaskPanel;
@property (nonatomic, retain) IBOutlet NSTableView *tableView;
@property (nonatomic, retain) IBOutlet NSTableView *doneTableView;

/* Interface Builder data (Controllers) */
@property (nonatomic, retain) IBOutlet NSArrayController *tasksController;
@property (nonatomic, retain) IBOutlet NSArrayController *doneTasksController;

/* Core Data business */
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;


/* GUI Actions*/
- (IBAction)saveAction:sender;
- (IBAction)filterTasks:(id)sender;
- (IBAction)addNewTask:(id)sender;
- (IBAction)removeSelectedTasks:(id)sender;
- (IBAction)markSelectedAsDone:(id)sender;
- (IBAction)openFeedback:(id)sender;
- (id)updateBadge;


/* Drag and Drop / Reordering helpers */
- (NSArray *)sortDescriptors;
- (NSArray *)tableViews;

@end
