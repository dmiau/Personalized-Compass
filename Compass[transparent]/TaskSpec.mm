//
//  TestManager-TaskSpec.cpp
//  Compass[transparent]
//
//  Created by Daniel on 3/3/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TaskSpec.h"
using namespace std;

#ifndef __IPHONE__
//--------------
// Test Spec Class
//--------------
TaskSpec::TaskSpec(TaskType inTaskType, NSMutableDictionary* myTestSpecDictionary,
                   DesktopViewController* desktopViewController)
{
    taskType = inTaskType;
    rootViewController = desktopViewController;
    testSpecDictionary = myTestSpecDictionary;
    // Assign default deviceType based on taskType
    switch (taskType) {
        case LOCATE:
            deviceType = PHONE;
            break;
        case TRIANGULATE:
            deviceType = WATCH;
            break;
        case ORIENT:
            deviceType = PHONE;
            break;
        case LOCATEPLUS:
            deviceType = WATCH;
            break;
        case DISTANCE:
            deviceType = PHONE;
            break;
        default:
            break;
    }
};

//http://stackoverflow.com/questions/695645/why-does-the-c-map-type-argument-require-an-empty-constructor-when-using
TaskSpec::TaskSpec(){
    
}


vector<int> TaskSpec::shuffleTests(){
    vector<int> shuffled_order;
    shuffled_order.clear();

    // Computer a random order
    // At this point we know this task contains trial_counter trials
    for (int i = 0; i < snapshot_array.size(); ++i){
        shuffled_order.push_back(i);
    }
    random_shuffle(shuffled_order.begin(), shuffled_order.end());
    return shuffled_order;
}
#endif


vector<int> NSArrayIntToVector(NSArray* inputArray){
    vector<int> output;
    for(int i = 0; i < [inputArray count]; ++i){
        output.push_back([inputArray[i] integerValue]);
    }
    return output;
}

// Convert an NSArray of string to a vector of CGPoint
vector<vector<int>> NSArrayStringToVector(NSArray* inputArray)
{
    vector<vector<int>> output;
    for(int i = 0; i < [inputArray count]; ++i){
        vector<int> temp;
        NSArray* t_array = [inputArray[i] componentsSeparatedByString:@","];
        temp.push_back([t_array[0] intValue]);
        temp.push_back([t_array[1] intValue]);
        output.push_back(temp);
    }
    return output;
}
