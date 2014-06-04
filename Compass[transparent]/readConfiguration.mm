//
//  readConfiguration.mm
//  Compass[transparent]
//
//  Created by dmiau on 4/17/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#include "compassModel.h"
#include <string>

using namespace std;

int readConfigurations(compassMdl* mdl_instance){
    
    
    NSString *jsonPath = [NSString stringWithUTF8String:mdl_instance->configuration_filename.c_str()];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSArray *jsonData= [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:&error];
//    NSLog(@"JSON: %@", jsonData[0]);
    if (error)
        return EXIT_FAILURE;
    
    for (int i = 0; i < [jsonData count]; ++i){
        NSString *key = jsonData[i][@"property"];
        
        if ([key isEqualToString:@"color_map"] ){
            // Need to handle color_map as a special case
            NSArray *color_list_root = jsonData[i][@"value"];
            
            // Allocate memory to hold color_map
            // http://stackoverflow.com/questions/936687/how-do-i-declare-a-2d-array-in-c-using-new
            // http://www.cplusplus.com/forum/beginner/51598/
            
            for (int j = 0; j< [jsonData[i][@"value"] count]; ++j){
                mdl_instance->color_map.push_back(new int[3]);
                mdl_instance->color_map[j][0] = [color_list_root[j][0] intValue];
                mdl_instance->color_map[j][1] = [color_list_root[j][1] intValue];
                mdl_instance->color_map[j][2] = [color_list_root[j][2] intValue];
            }
        }else if([jsonData[i][@"value"] isKindOfClass:[NSArray class]]){
//            NSLog(@"An array found!");
            NSMutableArray *mutableArray =
            [[NSMutableArray alloc] initWithCapacity:[jsonData[i][@"value"] count]];

            NSNumber *number;
            for (int j = 0; j < [jsonData[i][@"value"] count]; ++j){

                    number = jsonData[i][@"value"][j];
                [mutableArray addObject:number];
            }
            [mdl_instance->configurations setObject:mutableArray forKey:key];
        }else{
            // Handle the value differently depending on the type of object
            [mdl_instance->configurations setObject:jsonData[i][@"value"]
                                             forKey:key];
        }
    }
    
//    NSLog(@"%@", mdl_instance->configurations);
    
    return EXIT_SUCCESS;
}