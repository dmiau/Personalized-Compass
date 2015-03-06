//
//  historyParser.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 7/21/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "historyParser.h"
#include <stdexcept>

//----------------
// Read function
//----------------
int readHistoryKml(compassMdl* mdl){
    NSString* filename = mdl->history_filename;
    historyParser *myParser;
#ifdef __IPHONE__
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
        
        UIAlertController* alert = [UIAlertController
                                    alertControllerWithTitle:@"System Message"
                                    message:
                                    [NSString stringWithFormat:
                                     @"Failed to read the location file: %@",
                                     filename]
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction =
        [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
         {[alert dismissViewControllerAnimated:YES completion:nil];}];
        
        [alert addAction:defaultAction];
        return EXIT_FAILURE;
    }else{
        myParser = [[historyParser alloc] initWithData: data];
    }
    
#else
    myParser = [[historyParser alloc]
                initWithFileURL: [NSURL fileURLWithPath: filename]];
#endif
    myParser.parseFile;
    mdl->breadcrumb_array = myParser.breadcrumb_array;
    mdl->history_notes = myParser.history_notes;
    return EXIT_SUCCESS;
}

//----------------
// Class implementation
//----------------

@implementation historyParser
@synthesize breadcrumb_array;

-(id)initCommon{
    self = [super init];
    place_flag          =false;
    name_flag           =false;
    coord_flag          =false;
    notes_flag          =false;
    date_flag           =false;
    self.history_notes = @"";
    return self;
}


-(id)initWithFileURL: (NSURL*) in_fileurl{

    self = [self initCommon];
    
    fileurl = in_fileurl;
    in_data = nil;
    return self;
}

-(id)initWithData: (NSData*) inData{
    self = [self initCommon];
    fileurl = nil;
    in_data = inData;
    
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
        breadcrumb _breadcrumb;
        breadcrumb_array.push_back(_breadcrumb);
        place_flag = true;
    }else if ([elementName isEqualToString:@"name"]){
        name_flag = true;
    }else if ([elementName isEqualToString:@"coordinates"]){
        coord_flag = true;
    }else if ([elementName isEqualToString:@"notes"]){
        notes_flag = true;
    }else if ([elementName isEqualToString:@"date"]){
        date_flag = true;
    }
}

//----------------
// Found characters
//----------------
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (place_flag){
        if (name_flag){
            breadcrumb_array[breadcrumb_array.size()-1].name = string;
        }else if (coord_flag){
            // Need to somehow split the sting
            NSArray *_coord = [string componentsSeparatedByString:@","];
            // Note that in KML coordinates order are (lon, lat)
            
            // Populate MKPointAnnotation
            CLLocationCoordinate2D coord2D = CLLocationCoordinate2DMake
            ([_coord[1] floatValue],
             [_coord[0] floatValue]);
            breadcrumb_array[breadcrumb_array.size()-1].coord2D = coord2D;
        }else if (date_flag){
            breadcrumb_array[breadcrumb_array.size()-1].date_str = string;
        }
    }else if (notes_flag){
        self.history_notes = string;
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
    }else if ([elementName isEqualToString:@"notes"]){
        notes_flag = false;
    }else if ([elementName isEqualToString:@"date"]){
        date_flag = false;
    }
}

@end