//
//  iOSViewController+Files.m
//  Compass[transparent]
//
//  Created by Daniel on 2/13/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#ifdef __IPHONE__
//-------------------
// iOS
//-------------------
#import "iOSViewController.h"
@implementation iOSViewController (files)

//-------------
// Save file
//-------------
- (void) saveKMLwithType: (KMLTYPE) type{
    NSString *filename;
    NSString *content;
    bool hasError = false;
    if (type == LOCATION){
        filename = [self.model->location_filename lastPathComponent];
        content = genKMLString(self.model->data_array);
    }else if (type == SNAPSHOT){
        filename = self.model->snapshot_filename;
        content = genSnapshotString(self.model->snapshot_array);
    }
    
    if (self.model->filesys_type == DROPBOX){
        if (![self.model->dbFilesystem
              writeFileWithName:filename Content:content])
        {
            hasError = true;
        }
    }else{
        if (![self.model->docFilesystem
              writeFileWithName:filename Content:content])
        {
            hasError = true;
        }
    }
    
    if (hasError){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File System Error"
                                                        message:@"Fail to save the file."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        NSLog(@"Failed to write file.");
        [alert show];
    }
}
@end
#endif


#ifndef __IPHONE__
//-------------------
// Desktop (osx)
//-------------------
#import "DesktopViewController.h"
@implementation DesktopViewController (files)
- (void) saveKMLwithType: (KMLTYPE) type{
    NSString *filename;
    NSString *content;
    if (type == LOCATION){
        filename = [self.model->location_filename lastPathComponent];
        content = genKMLString(self.model->data_array);
    }else if (type == SNAPSHOT){
        filename = self.model->snapshot_filename;
        content = genSnapshotString(self.model->snapshot_array);
    }
 
    NSError *error;
    NSString *doc_path = [self.model->desktopDropboxDataRoot stringByAppendingPathComponent:filename];
    
    if (![content writeToFile:doc_path
                   atomically:YES encoding: NSASCIIStringEncoding
                        error:&error])
    {
        
        NSAlert *alert = [NSAlert alertWithMessageText:
                          [NSString stringWithFormat:@"Write %@ failed", doc_path]
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@""];
        [alert runModal];

    }
}
@end
#endif