//
//  readConfiguration.mm
//  Compass[transparent]
//
//  Created by dmiau on 4/17/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#include "compassModel.h"
#include <string>

#ifdef __IPHONE__
#include "filesystem.h"
#endif

using namespace std;

int readConfigurations(compassMdl* mdl_instance){
    
#ifdef __IPHONE__
    NSData *data = nil;
    NSString *jsonPath = mdl_instance->configuration_filename;
    
    if (mdl_instance->dbFilesystem.isReady &&
        mdl_instance->filesys_type == DROPBOX){
        data = [mdl_instance->dbFilesystem readFileFromName:
                [jsonPath lastPathComponent]];
    }
    
    if (!data){
        data = [mdl_instance->docFilesystem readFileFromName:
                [jsonPath lastPathComponent]];
        mdl_instance->filesys_type = IOS_DOC;
    }

    if (!data){
        throw(runtime_error("Failed to read the configuration file."));
        return EXIT_FAILURE;
    }
    
#else
    NSString *jsonPath = mdl_instance->configuration_filename;
    NSData *data = [NSData dataWithContentsOfFile:
         [mdl_instance->desktopDropboxDataRoot stringByAppendingPathComponent:
                    [jsonPath lastPathComponent]]];
#endif
    
    NSError *error = nil;
    NSArray *jsonData= [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:&error];
    if (error)
        return EXIT_FAILURE;
    
    for (int i = 0; i < [jsonData count]; ++i){
        NSString *key = jsonData[i][@"property"];
        
        // There could be two types of prefixes: iPhone and iPad
#if defined(__IPHONE__) && defined(__IPAD__)
        if ([key hasPrefix:@"iPad_"]){
            key = [key substringFromIndex:5];
        }
#elif __IPHONE__
        if ([key hasPrefix:@"iOS_"]){
            key = [key substringFromIndex:4];
        }
#endif
        
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
    
    mdl_instance->cache_configurations =
    [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject: mdl_instance->configurations]];    
    
//    NSLog(@"%@", mdl_instance->configurations);
    mdl_instance->configurationFileReadFlag = true;
    return EXIT_SUCCESS;
}