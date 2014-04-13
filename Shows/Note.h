//
//  Note.h
//  Shows
//
//  Created by CHIEN NGUYEN on 4/13/14.
//  Copyright (c) 2014 CHIEN NGUYEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Note : NSObject

@property(nonatomic)NSString*title;
@property(nonatomic)NSString*text;
@property(nonatomic)NSString *dateCreate;

-(id)initNote:(NSString*)noteTitle setText:(NSString*)noteText setDate:(NSString*)noteDate;

@end
