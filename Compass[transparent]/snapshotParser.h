//
//  snapshotParser.h
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

int readSnapshotKml(compassMdl* mdl);

@interface snapshotParser : NSObject <NSXMLParserDelegate>
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
    BOOL span_flag;
    BOOL orienttion_flag;
    BOOL kmlFilename_flag;
    BOOL address_flag;
    BOOL notes_flag;
    BOOL date_flag;
}
//snapshot_array stores the output
@property std::vector<snapshot> snapshot_array;
- (id)initWithFileURL: (NSURL*) in_fileurl;
- (id)initWithData: (NSData*) in_data;
- (int) parseFile;
@end