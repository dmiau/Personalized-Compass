//
//  testCodeInterpreter.mm
//  Compass[transparent]
//
//  Created by Daniel on 3/14/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "testCodeInterpreter.h"
#include "TaskSpec.h"

//------------
// Constructor
//------------
TestCodeInterpreter::TestCodeInterpreter(string input){
    code = input;
}


TestCodeInterpreter::TestCodeInterpreter(NSString* input){
    code = string([input UTF8String]);
}


string TestCodeInterpreter::genTaskInstruction(){
    string output;
    TaskType taskType = NSStringToTaskType([NSString stringWithUTF8String:code.c_str()]);
    
    switch (taskType) {
        case LOCATE:
            output = "Estimate the location of Subway[i], then hold the left button to mark your answer.";
            break;
        case DISTANCE:
            output = "Estimate the distance to Subway[i], then answer in the box on the right. Round your answer if necessary. (Your answer must be an integer multiple of x.)";
            break;
        case TRIANGULATE:
            output = "Estimate where you are on the desktop map, then hold the left button to mark your answer.";
            break;
        case ORIENT:
            output = "Estimate the direction of Subway[i], then rotate the red line (on iPhone) to indicate your answer.";
            break;
        case LOCATEPLUS:
            output = "Estimate the location of the coffee shop, then hold the left button to mark your answer.";
            break;
        default:
            break;
    }
    
    return output;
}

string TestCodeInterpreter::genTitle(){
    string output;
    
    TaskType taskType = NSStringToTaskType([NSString stringWithUTF8String:code.c_str()]);
    
    switch (taskType) {
        case LOCATE:
            output = "Where is the subway[i] station?";
            break;
        case DISTANCE:
            output = "How far is the subway[i] station?";
            break;
        case TRIANGULATE:
            output = "Where am I?";
            break;
        case ORIENT:
            output = "Which direction is the subway[i] station?";
            break;
        case LOCATEPLUS:
            output = "Where is the coffee shop?";
            break;
        default:
            break;
    }
    return output;
}

NSString* TestCodeInterpreter::genVideoName(){
    string output;
    
    TaskType taskType = NSStringToTaskType([NSString stringWithUTF8String:code.c_str()]);
    
    switch (taskType) {
        case LOCATE:
            output = "-phone-locate";
            break;
        case DISTANCE:
            output = "-phone-distance";
            break;
        case TRIANGULATE:
            output = "-watch-triangulate";
            break;
        case ORIENT:
            output = "-phone-direction";
            break;
        case LOCATEPLUS:
            output = "-watch-locate+";
            break;
        default:
            break;
    }
    VisualizationType visualizationType = NSStringToVisualizationType
    ([NSString stringWithUTF8String:code.c_str()]);
    
    switch (visualizationType) {
        case VIZPCOMPASS:
            output = "pcompass" + output;
            break;
        case VIZWEDGE:
            output = "wedge" + output;
            break;
        default:
            break;
    }
    
    return [NSString stringWithUTF8String:output.c_str()];
}


