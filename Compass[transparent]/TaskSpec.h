//
//  TaskSpec.h
//  Compass[transparent]
//
//  Created by Daniel on 3/3/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#ifndef Compass_transparent__TaskSpec_h
#define Compass_transparent__TaskSpec_h

#include <stdio.h>
#include <iostream>
#include <vector>
#include <map>
#include <random>

#import "compassModel.h"        //To use the data object
#import "compassRender.h"

#ifndef __IPHONE__
#import <Cocoa/Cocoa.h>
@class DesktopViewController;
//#else
//#import <UIKit/UIKit.h>
//@class iOSViewController;
#endif

using namespace std;

//------------------------------
// Test Specifications
//------------------------------
enum TaskType {LOCATE, TRIANGULATE, ORIENT, LOCATEPLUS, DISTANCE};
enum DataSetType {NORMAL, MUTANT};

inline string toString(TaskType taskType){
    string output;
    
    switch (taskType) {
        case LOCATE:
            output = "locate";
            break;
        case TRIANGULATE:
            output = "triangulate";
            break;
        case ORIENT:
            output = "orient";
            break;
        case LOCATEPLUS:
            output = "lplus";
            break;
        case DISTANCE:
            output = "distance";
            break;
        default:
            break;
    }
    
    return output;
}

inline string toString(DataSetType dataSetType){
    string output;
    switch (dataSetType) {
        case NORMAL:
            output = "normal";
            break;
        case MUTANT:
            output = "mutant";
            break;
        default:
            break;
    }    
    return output;
}


inline NSString* toNSString(TaskType taskType){
    string temp = toString(taskType);
    return [NSString stringWithUTF8String:temp.c_str()];
}

inline TaskType NSStringToTaskType(NSString* code){
    TaskType output;
    if ([code rangeOfString:toNSString(LOCATE)].location != NSNotFound)
    {
        output = LOCATE;
    }else if ([code rangeOfString:toNSString(DISTANCE)].location != NSNotFound){
        output = DISTANCE;
    }else if ([code rangeOfString:toNSString(TRIANGULATE)].location != NSNotFound){
        output = TRIANGULATE;
    }else if ([code rangeOfString:toNSString(ORIENT)].location != NSNotFound){
        output = ORIENT;
    }else if ([code rangeOfString:toNSString(LOCATEPLUS)].location != NSNotFound){
        output = LOCATEPLUS;
    }
    return output;
}


// Tools
// Convert an NSArray of int to a vector of int
vector<int> NSArrayIntToVector(NSArray* inputArray);
vector<float> NSArrayFloatToVector(NSArray* inputArray);
// Convert an NSArray of string to a vector of CGPoint
vector<vector<int>> NSArrayStringToVector(NSArray* inputArray);


//----------------------------------
// TestSpec class
//----------------------------------
class TaskSpec{
public:
    // Properties
    TaskType taskType;
    DeviceType deviceType;
    string identifier;
    
    vector<snapshot> snapshot_array;
    vector<snapshot> practice_snapshot_array; //store the practice snapshot
    
    bool isMutant;
    
    vector<pair<string, vector<int>>> code_location_vector; // For debug purpose
    NSMutableDictionary* testSpecDictionary;
public:
    // Constructor
    TaskSpec();

#ifndef __IPHONE__
    DesktopViewController* rootViewController;
    TaskSpec(TaskType inTaskType,
             NSMutableDictionary* testSpecDictionary,
             DesktopViewController* desktopViewController);
    vector<int> shuffleTests(std::mt19937 &generator);
    
    // Based on the task type, different data and snapshot will be generated
    // Task generation only takes place on OSX
    void generateLocationAndSnapshots(vector<data> &t_data_array,
                                      std::mt19937 &generator);
private:
    // Task specific generation file
    void generateLocateTests(vector<data> &t_data_array);
    
    void generateOrientTests(vector<data> &t_data_array);

    // Add one data and snapshot
    void addOneDataAndSnapshot(string trialString, CGPoint openGLPoint,
                               vector<data> &t_data_array);

    void generateTriangulateTests(vector<data> &t_data_array, std::mt19937 &generator);
    void generateLocatePlusTests(vector<data> &t_data_array, std::mt19937 &generator);

    pair<vector<vector<double>>, vector<vector<double>>> generateRandomTriangulateLocations(
                        std::mt19937  &generator,
                        vector<int> base_length_vector, vector<float> ratio_vecotr, vector<int> delta_theta_vecotr);

    void batchCommitLocationPairs(string postfix,
    pair<vector<vector<double>>, vector<vector<double>>> location_pairs,
                                  vector<int> is_answer_list,
                                  vector<data> &t_data_array);
    
    // Add two data and snapshot
    void addTwoDataAndSnapshot(string trialString,
                               vector<DoublePoint> openGLPoints,
                               vector<int> is_answer_list,
                               vector<double> truth_stats,
                               vector<data> &t_data_array);
#endif
};
#endif
