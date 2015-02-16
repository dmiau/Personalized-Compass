//
//  TestManager-Record.cpp
//  Compass[transparent]
//
//  Created by Daniel on 2/15/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include <stdio.h>
#include "TestManager.h"
#import "CHCSVParser.h"

//// Testing NSDate, and trying to build a timer
////    http://stackoverflow.com/questions/10787751/current-date-and-time-nsdate
//
//NSDate *start = [NSDate date];
//// do stuff...
//NSTimeInterval timeInterval = [start timeIntervalSinceNow];
//


void record::start(){
    startDate = [NSDate date];
}

void record::end(){
    elapsed_time = [startDate timeIntervalSinceNow];
    endDate = [NSDate date];
}

//-------------------
// Display record information
//-------------------
void record::display(){
    NSLog(@"%@", genSavableRecord());
}

//-------------------
// Generate an NSArray for saving
//-------------------
NSArray* record::genSavableRecord(){
    // Saving format:
    // ID, Code, StartTime, EndTime, ElapsedTime, Truth(x,y), Answer(x, y), Error
    NSDateFormatter *formatter =
    [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"NYC"]];
    
    NSString* idString = [NSString stringWithFormat:@"%d", snapshot_id];
    
    // Generate all the necessary ingredients
    NSString* startDateString = [formatter stringFromDate:startDate];
    NSString* endDateString = [formatter stringFromDate:endDate];
    
    NSString* elapsedTimeString = [NSString stringWithFormat:@"%f", elapsed_time];

#ifndef __IPHONE__
    NSString* truthString = NSStringFromPoint(ground_truth);
    NSString* answerString = NSStringFromPoint(answer);
#else
    NSString* truthString = NSStringFromCGPoint(ground_truth);
    NSString* answerString = NSStringFromCGPoint(answer);
#endif
    
    // Calculate the errors
    CGFloat xDist = (ground_truth.x - answer.x);
    CGFloat yDist = (ground_truth.y - answer.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    
    NSString* errorString = [NSString stringWithFormat:@"%f", distance];
    
    NSArray* output = @[idString, code,
                        startDateString, endDateString,
                        elapsedTimeString, truthString, answerString,
                        errorString];
    return output;
}

//-------------------
// Save the record vector
//-------------------

void TestManager::saveRecord(){
    // Make sure the output folder exists
    setupOutputFolder();
    NSString *folder_path = [model->desktopDropboxDataRoot
                             stringByAppendingString:test_foldername];
    NSString *out_file = [folder_path
                          stringByAppendingPathComponent:record_filename];
    CHCSVWriter *w = [[CHCSVWriter alloc] initForWritingToCSVFile:out_file];
    
    // http://stackoverflow.com/questions/1443793/iterate-keys-in-a-c-map
    
    // Header
    [w writeLineOfFields: @[@"ID", @"Code", @"StartTime", @"EndTime",
                            @"ElapsedTime", @"Truth(x,y)", @"Answer(x, y)",
                            @"Error"]];
    for (int i = 0; i < record_vector.size(); ++i){
        [w writeLineOfFields: record_vector[i].genSavableRecord()];
    }
}