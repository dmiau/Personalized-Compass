//
//  jsonReader.h
//  testJsoncpp
//
//  Created by dmiau on 2/6/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//

#ifndef __testJsoncpp__jsonReader__
#define __testJsoncpp__jsonReader__

#include <cstdio>
#include <cstring>
#include <iostream>
#include <fstream>
#include "commonInclude.h"
#include "compassModel.h"

// This is the JSON header
#include "jsoncpp/json.h"

enum json_type{LOCATION = 0, CONFIGURATION = 1};

int readFile(string filename, Json::Value& root);
int readConfigurations(compassMdl* mdl);
#endif /* defined(__testJsoncpp__jsonReader__) */
