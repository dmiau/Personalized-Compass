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


// readLocationKml read location from a provided kml file and load the locations
// to mdl's data_array property
// (in the process it also generates the texture for Open GL labels
void readLocationKml(compassMdl* mdl,
                             NSString *filename);

@interface xmlParser : NSObject <NSXMLParserDelegate>
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
// data_array stores the data of each location
@property std::vector<data> data_array;
- (id)initWithFileURL: (NSURL*) in_fileurl;
- (id)initWithData: (NSData*) in_data;
- (int) parseFile;

@end
