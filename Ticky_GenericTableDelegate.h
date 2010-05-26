//
//  Ticky_GenericTableDelegate.h
//  Ticky
//
//  Created by Thomas PELLETIER on 26/05/10.
//  Copyright 2010 Thomas PELLETIER. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Ticky_Globals.h"


@interface Ticky_GenericTableDelegate : NSObject {
	IBOutlet NSTableView *tableView;
	IBOutlet NSArrayController *tasksController;
	IBOutlet NSArrayController *otherTasksController;
}

@property (nonatomic, retain) IBOutlet NSTableView *tableView;
@property (nonatomic, retain) IBOutlet NSArrayController *tasksController;
@property (nonatomic, retain) IBOutlet NSArrayController *otherTasksController;

@end
