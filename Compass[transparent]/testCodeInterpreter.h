//
//  testCodeInterpreter.h
//  Compass[transparent]
//
//  Created by Daniel on 3/14/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#ifndef __Compass_transparent___testCodeInterpreter__
#define __Compass_transparent___testCodeInterpreter__

#include <stdio.h>
#include <string>
#include <iostream>

using namespace std;
class TestCodeInterpreter
{
public:
    string code;
public:
    TestCodeInterpreter(string input);
    TestCodeInterpreter(NSString* input);
    string genTaskInstruction();
    string genTitle();
    NSString* genVideoName();
};

#endif /* defined(__Compass_transparent___testCodeInterpreter__) */
