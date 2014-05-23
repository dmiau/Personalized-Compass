//
//  readConfiguration.cpp
//  Compass[transparent]
//
//  Created by dmiau on 4/17/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#include "jsonReader.h"
#include <string>

using namespace std;

int readConfigurations(compassMdl* mdl_instance){
    Json::Value root;
    string filename;
    filename = mdl_instance->configuration_filename;
    if (readFile(filename, root) != EXIT_SUCCESS)
        return EXIT_FAILURE;

    cout << root.toStyledString() << endl;
    
    for (int i = 0; i < root.size(); ++i){
        NSString *key = [NSString
                          stringWithUTF8String:root[i]["property"].asString().c_str()];
        
        if (root[i]["property"].asString().compare("color_map") == 0 ){
            // Need to handle color_map as a special case
            Json::Value color_list_root = root[i]["value"];
            
            
            // Allocate memory to hold color_map
            // http://stackoverflow.com/questions/936687/how-do-i-declare-a-2d-array-in-c-using-new
            // http://www.cplusplus.com/forum/beginner/51598/
            int color_n = color_list_root.size();
            
            for (int j = 0; j<color_n; ++j){
                mdl_instance->color_map.push_back(new int[3]);
                mdl_instance->color_map[j][0] = color_list_root[j][0].asInt();
                mdl_instance->color_map[j][1] = color_list_root[j][1].asInt();
                mdl_instance->color_map[j][2] = color_list_root[j][2].asInt();
            }
        }else if(root[i]["value"].isArray()){
//            NSLog(@"An array found!");
            NSMutableArray *mutableArray =
            [[NSMutableArray alloc] initWithCapacity:root[i]["value"].size()];

            NSNumber *number;
            for (int j = 0; j < root[i]["value"].size(); ++j){
//                cout <<root[i]["value"][j].toStyledString() << endl;
                    number = [NSNumber numberWithInt:root[i]["value"][j].asInt()];
                [mutableArray addObject:number];
            }
            [mdl_instance->configurations setObject:mutableArray forKey:key];
        }else{
            // Handle the value differently depending on the type of object
            if (root[i]["value"].isInt()){
                NSNumber *value = [NSNumber
                                   numberWithInt:root[i]["value"].asInt()];
                [mdl_instance->configurations setObject:value forKey:key];
            }else if (root[i]["value"].isDouble()){
                NSNumber *value = [NSNumber
                                   numberWithFloat:root[i]["value"].asFloat()];
                [mdl_instance->configurations setObject:value forKey:key];
            }else if (root[i]["value"].isString()){
                NSString *value = [NSString
                         stringWithUTF8String:root[i]["value"].asString().c_str()];
                [mdl_instance->configurations setObject:value forKey:key];
            }
        }
    }
    
//    NSLog(@"%@", mdl_instance->configurations);
    
    return EXIT_SUCCESS;
}