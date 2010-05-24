//
//  Ticky_AddTaskPanel.h
//  Ticky
//
//  Created by Thomas PELLETIER on 22/04/10.
//  Copyright 2010 Thomas PELLETIER. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Ticky_Globals.h"

@interface Ticky_AddTaskPanel : NSPanel{
	
	IBOutlet NSTextField *taskField;
	
}

@property (assign) IBOutlet NSTextField *taskField;

- (IBAction)registerNewTask:(id)sender;

@end
