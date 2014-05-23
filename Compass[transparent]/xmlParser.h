//
//  xmlParser.h
//  playCocoa
//
//  Created by Daniel Miau on 3/20/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <iostream>
#include <vector>
#include "compassModel.h"

using namespace std;

int readLocationKml(compassMdl* mdl);

@interface xmlParser : NSObject <NSXMLParserDelegate>
{
    // instance variables are like (private) properties
    
    NSXMLParser *parser;
    // Temporary variable to hold intermediate parsing results
    NSMutableString *element;
    string _str;
    string filename;
    BOOL place_flag;
    BOOL name_flag;
    BOOL coord_flag;
    // data_array stores the data of each location
}

@property std::vector<data> data_array;

- (id)initWithFilename: (string) in_filename;
- (int) parseFile;

@end
