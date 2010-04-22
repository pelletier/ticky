//
//  Ticky_AppDelegate.h
//  Ticky
//
//  Created by Thomas PELLETIER on 13/04/10.
//  Copyright __MyCompanyName__ 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Ticky_AddTaskPanel.h"

@interface Ticky_AppDelegate : NSObject 
{
    NSWindow *window;
    Ticky_AddTaskPanel *addTaskPanel;
	
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
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

- (IBAction)saveAction:sender;
- (IBAction)filterTasks:(id)sender;
- (IBAction)addNewTask:(id)sender;
- (IBAction)markSelectedAsDone:(id)sender;

- (void)updateBadge;
   
@end
