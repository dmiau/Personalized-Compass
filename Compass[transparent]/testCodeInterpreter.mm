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
            output = "Estimate the location of Subway[i], \nthen hold the left button to mark your answer.";
            break;
        case DISTANCE:
            output = "Estimate the distance to Subway[i], \n(in integer multiples of x)";
            break;
        case TRIANGULATE:
            output = "Estimate the location of where you are, \nthen hold the left button to mark your answer.";
            break;
        case ORIENT:
            output = "Estimate the direction of Subway[i], \nthen rotate the line to indicate your answer.";
            break;
        case LOCATEPLUS:
            output = "Estimate the direction of the coffee shop, \nthen hold the left button to mark your answer.";
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