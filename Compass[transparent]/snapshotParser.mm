//
//  snapshotParser.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 7/21/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "snapshotParser.h"
#include <stdexcept>

//----------------
// Read function
//----------------
int readSnapshotKml(compassMdl* mdl){
    NSString* filename = mdl->snapshot_filename;
    snapshotParser *myParser;
#ifdef __IPHONE__
    // iOS
    NSData* data = nil;
    if (mdl->dbFilesystem.isReady &&
        mdl->filesys_type == DROPBOX){
        data = [mdl->dbFilesystem readFileFromName:
                [filename lastPathComponent]];
    }
    
    if (!data){
        data = [mdl->docFilesystem readFileFromName:
                [filename lastPathComponent]];
        mdl->filesys_type = IOS_DOC;
    }
    
    if (!data){
        data = [mdl->docFilesystem readBundleFileFromName:
                [filename lastPathComponent]];
        mdl->filesys_type = BUNDLE;
    }
    
    if (!data){
        throw(runtime_error("Failed to read the location file."));
        return EXIT_FAILURE;
    }else{
        myParser = [[snapshotParser alloc] initWithData: data];
    }
    
#else
    // Desktop
    myParser = [[snapshotParser alloc]
                initWithFileURL: [NSURL fileURLWithPath:
    [mdl->desktopDropboxDataRoot stringByAppendingPathComponent:filename]]];
#endif
    myParser.parseFile;
    
    
    // Run sanity check before sendig the snapshot_array to the model
    // Because some of the newly added field might be empty
    for (int i = 0; i < myParser.snapshot_array.size(); ++i){
        myParser.snapshot_array[i].runSanityCheck();
    }
    
    mdl->snapshot_array = myParser.snapshot_array;
    
    return EXIT_SUCCESS;
}

//----------------
// Class implementation
//----------------
@implementation snapshotParser
@synthesize snapshot_array;

-(id)initWithFileURL: (NSURL*) in_fileurl{
    self = [super init];
    fileurl = in_fileurl;
    in_data = nil;
    
    place_flag          =false;
    name_flag           =false;
    coord_flag          =false;
    orienttion_flag     =false;
    kmlFilename_flag    =false;
    notes_flag          = false;
    date_flag           = false;
    selected_id_flag    = false;
    visualization_flag  = false;
    device_flag         = false;
    
    osx_coord_flag      = false;
    osx_span_flag       = false;
    is_answer_list_flag   = false;
    ios_display_wh_flag = false;
    eios_display_wh_flag= false;
    osx_display_wh_flag = false;
    
    return self;
}

-(id)initWithData: (NSData*) inData{
    self = [super init];
    fileurl = nil;
    in_data = inData;
    
    place_flag          =false;
    name_flag           =false;
    coord_flag          =false;
    orienttion_flag     =false;
    kmlFilename_flag    =false;
    notes_flag          = false;
    date_flag           = false;
    selected_id_flag    = false;
    visualization_flag  = false;
    device_flag         = false;
    
    osx_coord_flag      = false;
    osx_span_flag       = false;
    is_answer_list_flag   = false;
    ios_display_wh_flag = false;
    eios_display_wh_flag= false;
    osx_display_wh_flag = false;
    return self;
}

-(int) parseFile{
    
    if (!in_data){
        parser = [[NSXMLParser alloc]
                  initWithContentsOfURL: fileurl];
    }else{
        parser = [[NSXMLParser alloc] initWithData: in_data];
    }
    
    [parser setDelegate:self];
    BOOL success = [parser parse];
    
    // test the result
    if (!success){
        throw(std::runtime_error("Failed to parse the document!"));
    }
    return success;
}

//----------------
// Start
//----------------
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    // There are five tags I care about
    if ([elementName isEqualToString:@"Placemark"]) {
        snapshot _snapshot;
        snapshot_array.push_back(_snapshot);
        place_flag = true;
    }else if ([elementName isEqualToString:@"name"]){
        name_flag = true;
    }else if ([elementName isEqualToString:@"coordinates"]){
        coord_flag = true;
    }else if ([elementName isEqualToString:@"spans"]){
        span_flag = true;
    }else if ([elementName isEqualToString:@"orientation"]){
        orienttion_flag = true;
    }else if ([elementName isEqualToString:@"kmlFilename"]){
        kmlFilename_flag = true;
    }else if ([elementName isEqualToString:@"address"]){
        address_flag = true;
    }else if ([elementName isEqualToString:@"notes"]){
        notes_flag = true;
    }else if ([elementName isEqualToString:@"date"]){
        date_flag = true;
    }else if ([elementName isEqualToString:@"selected_ids"]){
        selected_id_flag = true;
    }else if ([elementName isEqualToString:@"visualizationType"]){
        visualization_flag = true;
    }else if ([elementName isEqualToString:@"deviceType"]){
        device_flag = true;
    }
    
    else if ([elementName isEqualToString:@"osx_coord"]){
        osx_coord_flag = true;
    }else if ([elementName isEqualToString:@"osx_span"]){
        osx_span_flag = true;
    }else if ([elementName isEqualToString:@"is_answer_list"]){
        is_answer_list_flag = true;
    }else if ([elementName isEqualToString:@"ios_display_wh"]){
        ios_display_wh_flag = true;
    }else if ([elementName isEqualToString:@"eios_display_wh"]){
        eios_display_wh_flag = true;
    }else if ([elementName isEqualToString:@"osx_display_wh"]){
        osx_display_wh_flag = true;
    }
    
    
}

//----------------
// Found characters
//----------------
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (place_flag){
        if (name_flag){
            snapshot_array[snapshot_array.size()-1].name = string;
        }else if (coord_flag){
            // Need to somehow split the sting
            NSArray *_coord = [string componentsSeparatedByString:@","];
            // Note that in KML coordinates order are (lon, lat)
            
            // Populate MKPointAnnotation
            CLLocationCoordinate2D coord2D = CLLocationCoordinate2DMake
            ([_coord[1] floatValue],
             [_coord[0] floatValue]);
            snapshot_array[snapshot_array.size()-1].coordinateRegion.center = coord2D;
        }else if (span_flag){
            // Need to somehow split the sting
            NSArray *_coord = [string componentsSeparatedByString:@","];
            // Note that in KML coordinates order are (lon, lat)
            
            snapshot_array[snapshot_array.size()-1]
            .coordinateRegion.span.longitudeDelta = [_coord[0] floatValue];
            snapshot_array[snapshot_array.size()-1]
            .coordinateRegion.span.latitudeDelta = [_coord[1] floatValue];
        }else if (orienttion_flag){
            snapshot_array[snapshot_array.size()-1].orientation =
            [string floatValue];
        }else if (kmlFilename_flag){
            snapshot_array[snapshot_array.size()-1].kmlFilename = string;
        }else if (address_flag){
            snapshot_array[snapshot_array.size()-1].address = string;
        }else if (notes_flag){
            snapshot_array[snapshot_array.size()-1].notes = string;
        }else if (date_flag){
            snapshot_array[snapshot_array.size()-1].date_str = string;
        }else if (selected_id_flag){
            // Need to somehow split the sting
            NSArray *id_array = [string componentsSeparatedByString:@","];
            for (NSString *anItem in id_array){
                snapshot_array[snapshot_array.size()-1].
                selected_ids.push_back([anItem integerValue]);
            }
        }else if (visualization_flag){
            snapshot_array[snapshot_array.size()-1].visualizationType =
            (VisualizationType)[string integerValue];
        }else if (device_flag){
            snapshot_array[snapshot_array.size()-1].deviceType =
            (DeviceType)[string integerValue];
        }
        
        else if (osx_coord_flag){
            // Need to somehow split the sting
            NSArray *_coord = [string componentsSeparatedByString:@","];
            // Note that in KML coordinates order are (lon, lat)
            
            // Populate MKPointAnnotation
            CLLocationCoordinate2D coord2D = CLLocationCoordinate2DMake
            ([_coord[1] floatValue],
             [_coord[0] floatValue]);
            snapshot_array[snapshot_array.size()-1].osx_coordinateRegion.center = coord2D;
        }else if (osx_span_flag){
            // Need to somehow split the sting
            NSArray *_coord = [string componentsSeparatedByString:@","];
            // Note that in KML coordinates order are (lon, lat)
            
            snapshot_array[snapshot_array.size()-1]
            .osx_coordinateRegion.span.longitudeDelta = [_coord[0] floatValue];
            snapshot_array[snapshot_array.size()-1]
            .osx_coordinateRegion.span.latitudeDelta = [_coord[1] floatValue];
        }
        
        else if (is_answer_list_flag){
            // Need to somehow split the sting
            NSArray *id_array = [string componentsSeparatedByString:@","];
            for (NSString *anItem in id_array){
                snapshot_array[snapshot_array.size()-1].
                is_answer_list.push_back([anItem integerValue]);
            }
        }
        
        else if (ios_display_wh_flag){
            // Need to somehow split the sting
            NSArray *id_array = [string componentsSeparatedByString:@","];
            snapshot_array[snapshot_array.size()-1].ios_display_wh.x =
            [id_array[0] floatValue];
            snapshot_array[snapshot_array.size()-1].ios_display_wh.y =
            [id_array[1] floatValue];
        }
        
        else if (eios_display_wh_flag){
            // Need to somehow split the sting
            NSArray *id_array = [string componentsSeparatedByString:@","];
            snapshot_array[snapshot_array.size()-1].eios_display_wh.x =
            [id_array[0] floatValue];
            snapshot_array[snapshot_array.size()-1].eios_display_wh.y =
            [id_array[1] floatValue];
        }
        
        else if (osx_display_wh_flag){
            // Need to somehow split the sting
            NSArray *id_array = [string componentsSeparatedByString:@","];
            snapshot_array[snapshot_array.size()-1].osx_display_wh.x =
            [id_array[0] floatValue];
            snapshot_array[snapshot_array.size()-1].osx_display_wh.y =
            [id_array[1] floatValue];
        }
        
    }
}

//----------------
// End
//----------------
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"Placemark"]) {
        place_flag = false;
    }else if ([elementName isEqualToString:@"name"]){
        name_flag = false;
    }else if ([elementName isEqualToString:@"coordinates"]){
        coord_flag = false;
    }else if ([elementName isEqualToString:@"spans"]){
        span_flag = false;
    }else if ([elementName isEqualToString:@"orientation"]){
        orienttion_flag = false;
    }else if ([elementName isEqualToString:@"kmlFilename"]){
        kmlFilename_flag = false;
    }else if ([elementName isEqualToString:@"address"]){
        address_flag = false;
    }else if ([elementName isEqualToString:@"notes"]){
        notes_flag = false;
    }else if ([elementName isEqualToString:@"date"]){
        date_flag = false;
    }else if ([elementName isEqualToString:@"selected_ids"]){
        selected_id_flag = false;
    }else if ([elementName isEqualToString:@"visualizationType"]){
        visualization_flag = false;
    }else if ([elementName isEqualToString:@"deviceType"]){
        device_flag = false;
    }
    
    else if ([elementName isEqualToString:@"osx_coord"]){
        osx_coord_flag = false;
    }else if ([elementName isEqualToString:@"osx_span"]){
        osx_span_flag = false;
    }else if ([elementName isEqualToString:@"is_answer_list"]){
        is_answer_list_flag = false;
    }else if ([elementName isEqualToString:@"ios_display_wh"]){
        ios_display_wh_flag = false;
    }else if ([elementName isEqualToString:@"eios_display_wh"]){
        eios_display_wh_flag = false;
    }else if ([elementName isEqualToString:@"osx_display_wh"]){
        osx_display_wh_flag = false;
    }
}
@end