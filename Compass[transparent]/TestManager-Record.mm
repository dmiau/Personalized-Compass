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

#ifndef __IPHONE__
#import "DesktopViewController.h"
#else
#import "iOSViewController.h"
#endif

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

//http://stackoverflow.com/questions/1878907/the-smallest-difference-between-2-angles
double modplus(double a, double n){
    return a - floor(a/n) *n;
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

    //-------------
    // isAnswerFlag string
    //-------------
    NSString* isAnswerString = [NSString stringWithFormat:@"%d", (int)isAnswered];

    //-------------
    // hasConnectionIssue string
    //-------------
    NSString* hasConnectionIssueString = [NSString stringWithFormat:@"%d", (int)hasConnectionIssue];
    
    //-------------
    // idString
    //-------------
    NSString* idString = [NSString stringWithFormat:@"%d", snapshot_id];

    //-------------
    // startDateString
    //-------------
    // Generate all the necessary ingredients
    NSString* startDateString;
    if (startDate){
        startDateString = [formatter stringFromDate:startDate];
    }else{
        startDateString = @"N/A";
    }

    //-------------
    // endDateString
    //-------------
    NSString* endDateString;
    if (endDate){
        endDateString = [formatter stringFromDate:endDate];
    }else{
        endDateString = @"N/A";
    }
    
    //-------------
    // elapsedTimeString
    //-------------
    NSString* elapsedTimeString = [NSString stringWithFormat:@"%f", abs(elapsed_time)];

    //-------------
    // truthString
    //-------------
#ifndef __IPHONE__
    NSString* truthCGPointString = NSStringFromPoint(cgPointTruth);
    NSString* answerCGPointString = NSStringFromPoint(cgPointAnswer);
#else
    NSString* truthCGPointString = NSStringFromCGPoint(cgPointTruth);
    NSString* answerCGPointString = NSStringFromCGPoint(cgPointAnswer);
#endif
    NSString* truthDobuleString = [NSString stringWithFormat:@"%f", doubleTruth];
    NSString* answerDobuleString = [NSString stringWithFormat:@"%f", doubleAnswer];
    
    //-------------
    // errors
    //-------------
    // Calculate the errors
    CGFloat xDist = (cgPointTruth.x - cgPointAnswer.x);
    CGFloat yDist = (cgPointTruth.y - cgPointAnswer.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    
    NSString* errorCGPointString = [NSString stringWithFormat:@"%f", distance];
    
    NSString* errorDobuleString;
    if ([code rangeOfString:toNSString(DISTANCE)].location != NSNotFound){
        errorDobuleString = [NSString stringWithFormat:@"%d",
                             static_cast<int>(abs(round(doubleTruth) - round(doubleAnswer)) +0.5)];
    }else if ([code rangeOfString:toNSString(ORIENT)].location != NSNotFound){
        // Always get the smallest angle as the error
        // This is to handle the situation like 315-10,
        // the correct answer should be 55.
        double diff;
        diff = doubleTruth - doubleAnswer;
        diff = modplus((diff+180), 360)-180;
        
        errorDobuleString = [NSString stringWithFormat:@"%f",
                             abs(diff)];
    }else{
        errorDobuleString = [NSString stringWithFormat:@"%f",
                             abs(doubleTruth - doubleAnswer)];
    }

    //-------------
    // Debugging/supporting information
    //-------------
#ifndef __IPHONE__
    NSString* cgSupport1String = NSStringFromPoint(cgSupport1);
    NSString* cgSupport2String = NSStringFromPoint(cgSupport2);
    NSString* opengGLXYString = NSStringFromPoint(cgPointOpenGL);
#else
    NSString* cgSupport1String = NSStringFromCGPoint(cgSupport1);
    NSString* cgSupport2String = NSStringFromCGPoint(cgSupport2);
    NSString* opengGLXYString = NSStringFromCGPoint(cgPointOpenGL);
#endif
    NSString* display_radiusString = [NSString stringWithFormat:@"%f", display_radius];

    
    //-------------
    // Task Error
    //-------------
    NSString* taskErrorString;
    
    if (([code rangeOfString:toNSString(DISTANCE)].location != NSNotFound)
        || ([code rangeOfString:toNSString(ORIENT)].location != NSNotFound))
        
    {
        taskErrorString = errorDobuleString;
    }else{
        taskErrorString = errorCGPointString;
    }
    
    //-------------
    // Consolidate all strings into an array
    //-------------
    // Make the 4rd column time difference
    // Make the 5th column error
    
    NSArray* output = @[idString,
                        code,
                        isAnswerString,
                        taskErrorString,
                        startDateString, endDateString, elapsedTimeString,
                        hasConnectionIssueString,
                        truthCGPointString, answerCGPointString, errorCGPointString,
                        truthDobuleString, answerDobuleString, errorDobuleString,
                        cgSupport1String, cgSupport2String,
                        display_radiusString, opengGLXYString];
    return output;
}

//-------------------
// Save the record vector
//-------------------

void TestManager::saveRecord(NSString *out_file, bool forced){
    
    //--------------
    // Check if a file exists already
    //--------------
    if ([[NSFileManager defaultManager] fileExistsAtPath:
          out_file])
    {
        if (!forced){
            [rootViewController displayPopupMessage:
             [NSString stringWithFormat:@"%@ already exists. _1 postfixed will be added to the saved file", out_file]];
            
            //----------------------
            // Compute a new name if it is not in the forced mode
            //----------------------
            out_file = [out_file stringByReplacingOccurrencesOfString:@".dat"                                                           withString:@"_1.dat"];
        }
    }
    
    NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:out_file append:NO];
    [output open];
//    CHCSVWriter *w = [[CHCSVWriter alloc] initForWritingToCSVFile:out_file];
    
    CHCSVWriter *w = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:';'];
    
    // http://stackoverflow.com/questions/1443793/iterate-keys-in-a-c-map
    
    // Header
    [w writeLineOfFields: @[@"SnapshotID",
                            @"Code",
                            @"isAnswered",
                            @"taskError",
                            @"StartTime", @"EndTime", @"ElapsedTime",
                            @"hasConnectionIssue",
                            @"Truth_XY", @"Answer_XY", @"Error_LocationDiff",
                            @"Truth_double", @"Answer_double", @"Error_double",
                            @"Support1", @"Support2",
                            @"DisplayRadius", @"OpenGL_XY"]];
    for (int i = 0; i < record_vector.size(); ++i){
        [w writeLineOfFields: record_vector[i].genSavableRecord()];
    }
    [output close];
    
    if ([out_file rangeOfString:@"Backup"].location == NSNotFound){
        [rootViewController displayPopupMessage:
         [NSString stringWithFormat:@"%@ has been saved successfully.", out_file]];
    }
}