//
//  CustomPointAnnotation.m
//  Compass[transparent]
//
//  Created by dmiau on 7/6/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "CustomPointAnnotation.h"

@implementation CustomPointAnnotation

-(id)init{
    
    self = [super init];
    self.notes = @"";
    self.address = @"";
    self.data_id = 0;
    self.subtitle = @"";
    return self;
}
@end
