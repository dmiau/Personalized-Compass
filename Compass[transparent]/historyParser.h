//
//  historyParser.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 7/21/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <iostream>
#include <vector>
#include "compassModel.h"

using namespace std;

@interface historyParser : NSObject <NSXMLParserDelegate>
{
    // instance variables are like (private) properties
    NSXMLParser *parser;
    // Temporary variable to hold intermediate parsing results
    NSMutableString *element;
    string _str;
    NSURL* fileurl;
    NSData* in_data;
    
    BOOL place_flag;
    BOOL name_flag;
    BOOL coord_flag;
}
//snapshot_array stores the output
@property std::vector<breadcrumb> breadcrumb_array;
- (id)initWithFileURL: (NSURL*) in_fileurl;
- (id)initWithData: (NSData*) in_data;
- (int) parseFile;
@end