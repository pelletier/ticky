//
//  Task.h
//  Ticky
//
//  Created by Thomas PELLETIER on 25/04/10.
//  Copyright 2010 Thomas PELLETIER. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Task :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * Content;
@property (nonatomic, retain) NSNumber * Done;

- (NSString*) identifier;

@end



