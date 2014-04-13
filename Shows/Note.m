//
//  Note.m
//  Shows
//
//  Created by CHIEN NGUYEN on 4/13/14.
//  Copyright (c) 2014 CHIEN NGUYEN. All rights reserved.
//

#import "Note.h"

@implementation Note
@synthesize title,text,dateCreate;

-(id)initNote:(NSString*)noteTitle setText:(NSString*)noteText setDate:(NSString*)noteDate
{
    self = [super init];
    if(self)
    {
        self.title = noteTitle;
        self.text = noteText;
        self.dateCreate = noteDate;
    }
    return self;
}

@end
