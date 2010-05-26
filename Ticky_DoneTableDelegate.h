//
//  Ticky_DoneTableDelegate.h
//  Ticky
//
//  Created by Thomas PELLETIER on 26/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Ticky_Globals.h"


@interface Ticky_DoneTableDelegate : NSObject {
	NSArray *_sortDescriptors;
	
	IBOutlet NSTableView *tableView;
	IBOutlet NSArrayController *tasksController;
}

@property (nonatomic, retain) IBOutlet NSTableView *tableView;
@property (nonatomic, retain) IBOutlet NSArrayController *tasksController;

@end
