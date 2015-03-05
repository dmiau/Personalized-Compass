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
TaskSpec::TaskSpec(TaskType inTaskType, DesktopViewController* desktopViewController)
{
    taskType = inTaskType;
    rootViewController = desktopViewController;
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


