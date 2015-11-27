//
//  AppDelegate.m
//  iphone
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "AppDelegate.h"
#import <Dropbox/Dropbox.h>
#import <CoreData/CoreData.h>
#import "Place.h"
#import "iOSViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation AppDelegate

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [GMSServices provideAPIKey:@"AIzaSyDdOmlH3SRnitZxFkhlQz7W81ERDShHXMk"];
    
    NSManagedObjectContext *context = [self managedObjectContext];
//    [self deleteAllObjects:@"Place" in:context];
//    [self deleteAllObjects:@"Area" in:context];
//    Place *p1 = [NSEntityDescription
//                 insertNewObjectForEntityForName:@"Place"
//                 inManagedObjectContext:context];
//    
//    p1.name = @"Time Square";
//    p1.lon = [NSNumber numberWithDouble:-73.9855];
//    p1.lat = [NSNumber numberWithDouble:40.7579];
//    p1.area = @"New York";
//    
//    Place *p2 = [NSEntityDescription
//                 insertNewObjectForEntityForName:@"Place"
//                 inManagedObjectContext:context];
//    
//    p2.name = @"United Nations";
//    p2.lon = [NSNumber numberWithDouble:-73.967729];
//    p2.lat = [NSNumber numberWithDouble:40.748961];
//    p2.area = @"New York";
//    
//    Place *p3 = [NSEntityDescription
//                 insertNewObjectForEntityForName:@"Place"
//                 inManagedObjectContext:context];
//    
//    p3.name = @"Newark Liberty International Airport";
//    p3.lon = [NSNumber numberWithDouble:-74.1745];
//    p3.lat = [NSNumber numberWithDouble:40.6895];
//    p3.area = @"New Jersey";
    
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Sorry, an error occurred while saving: %@", [error localizedDescription]);
    }
    
    return YES;
}


/*
 * You'll need to handle requests sent to your app from the linking dialog
 */

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation
{
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        NSLog(@"App linked successfully!");
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PersonalCompass.sqlite"];
    NSError *error = nil;
    //    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    //
    //    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
    //
    //        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    //        abort();
    //    }
    //
    //    return __persistentStoreCoordinator;
    //
    //
    
    /*
     Set up the store.
     For the sake of illustration, provide a pre-populated default store.
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:[storeURL path]] || YES) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"PersonalCompass"      ofType:@"sqlite"];
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:[storeURL path] error:NULL];
        }
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath:[storeURL path]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber   numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption , nil];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    [self addListernToStoreChanges];
    NSPersistentStore *seedStore = [__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error];
    
    if (seedStore) {
        NSLog(@"error loading old store");
    }

    NSDictionary *iCloudOptions = @{NSPersistentStoreUbiquitousContentNameKey: @"MyAppCloudStore"};
    NSURL *store_URL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PersonalCompass2.sqlite"];
    if (![__persistentStoreCoordinator migratePersistentStore:seedStore toURL:store_URL options:iCloudOptions withType:NSSQLiteStoreType error:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    //    NSURL *finaliCloudURL = [store URL];
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    NSLog(@"FUN %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void) deleteAllObjects: (NSString *) entityDescription in: (NSManagedObjectContext *) managedObjectContext {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
        [managedObjectContext deleteObject:managedObject];
        NSLog(@"%@ object deleted",entityDescription);
    }
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}

-(void) addListernToStoreChanges {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(storeWillChange:)
                   name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                 object:__persistentStoreCoordinator];
    
    [center addObserver:self
               selector:@selector(storeDidChange:)
                   name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                 object:__persistentStoreCoordinator];
    
    [center addObserver:self
           selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
             object:__persistentStoreCoordinator];
}

-(void) storeDidChange: (NSNotification *) n {
    //store has changed
    // Refresh UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
                                                        object:nil
                                                      userInfo:nil];
}

-(void) storeWillChange: (NSNotification *) n {
    [[self managedObjectContext] performBlockAndWait:^{
        NSError *error;
        if ([[self managedObjectContext] hasChanges]) {
            [[self managedObjectContext] save:&error];
        }
        
        [[self managedObjectContext] reset];
    }];
    
    // now reset your UI to be prepared for a totally different
    // set of data 
}

-(void) persistentStoreDidImportUbiquitousContentChanges: (NSNotification *) n {
    //update the context of the user interface
    [__managedObjectContext performBlock:^{
        [__managedObjectContext mergeChangesFromContextDidSaveNotification:n];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
    }];
}

@end