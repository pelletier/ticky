//
//  Ticky_AppDelegate.h
//  Ticky
//
//  Created by Thomas PELLETIER on 13/04/10.
//  Copyright __MyCompanyName__ 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Ticky_AppDelegate : NSObject 
{
    NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	IBOutlet NSArrayController *tasksController;
	IBOutlet NSSearchField *searchField;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;
- (IBAction)filterTasks:(id)sender;

@end
