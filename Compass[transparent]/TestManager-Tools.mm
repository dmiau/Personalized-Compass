//
//  TestManager-Tools.mm
//  Compass[transparent]
//
//  Created by Daniel on 3/14/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TestManager.h"

bool replace(std::string& str, const std::string& from, const std::string& to) {
    size_t start_pos = str.find(from);
    if(start_pos == std::string::npos)
        return false;
    str.replace(start_pos, from.length(), to);
    return true;
}

string extractCode(NSString* snapshot_name){
    NSRange range = [snapshot_name rangeOfString:@":" options:NSBackwardsSearch];
    string output = string([[snapshot_name substringToIndex:range.location] UTF8String ]);
    if ([snapshot_name hasSuffix:@"t"]){
        output = output + ":t";
    }
    
    return output;
}




string extractUerVisibleCode(NSString* snapshot_name){
    NSRange range = [snapshot_name rangeOfString:@":" options:NSBackwardsSearch];
    string output = string([[snapshot_name substringToIndex:range.location] UTF8String ]);
    
    replace(output, "wedge", "w");
    replace(output, "pcompass'", "c");
    
    if ([snapshot_name hasSuffix:@"t"]){
        output = output + ":training";
    }
    
    return output;
}