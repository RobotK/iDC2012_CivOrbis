//
//  CIVOAppDelegate.m
//  Civis Orbis
//
//  Created by Kris Markel on 7/21/12.
/*

Copyright (c) 2012, Nelson Ferraz and Kris Markel
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

	• Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	• Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/
//

#import "CIVOAppDelegate.h"

#import "City.h"
#import "CIVOMasterViewController.h"
#import "MBProgressHUD.h"
#import "POI.h"
#import "Tour.h"

NSString * const CIVODataImportedUserDefaultsKey = @"CIVODataImportedUserDefaultsKey";

@interface CIVOAppDelegate()

- (void) importData;

@end

@implementation CIVOAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIFont *titleFont = [UIFont fontWithName:@"IM FELL English" size:0.0];
	
	NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: titleFont, UITextAttributeFont, nil];
	[[UINavigationBar appearance] setTitleTextAttributes:titleTextAttributes];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	// Override point for customization after application launch.
	
	CIVOMasterViewController *masterViewController = [[CIVOMasterViewController alloc] initWithNibName:@"CIVOMasterViewController" bundle:nil];
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
	[self.navigationController setNavigationBarHidden:YES];

	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.translucent = YES;
	
	masterViewController.managedObjectContext = self.managedObjectContext;
	
	self.window.rootViewController = self.navigationController;
	[self.window makeKeyAndVisible];
	
	[UIView animateWithDuration:0.3 animations:^{
		masterViewController.splashScreenImage.alpha = 0.0;
	} completion:^(BOOL finished) {
		[masterViewController.splashScreenImage removeFromSuperview];
	}];
	
	[self importData];
	
	return YES;
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
	
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Civis_Orbis" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Civis_Orbis.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Private

- (void) importData
{
	BOOL dataImported = [[NSUserDefaults standardUserDefaults] boolForKey:CIVODataImportedUserDefaultsKey];
	
	if (!dataImported) {
		
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
		hud.labelText = NSLocalizedString(@"Importing Data", nil);
		
		dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

			__block BOOL importSucceeded = YES;
			NSURL *dataURL = [[NSBundle mainBundle] URLForResource:@"civitates" withExtension:@"json"];
			NSData *data;
			
			if (dataURL) {

				NSError *dataReadError;
				data = [NSData dataWithContentsOfURL:dataURL options:0 error:&dataReadError];
				if (!data) {
					NSLog(@"Could not read data file %@. Error: %@", dataURL, dataReadError);
					importSucceeded = NO;
				}
				
			} else {

				NSLog(@"Could not get data URL from the bundle.");
				importSucceeded = NO;

			}
			
			id JSONData;
			
			if (importSucceeded) {

				NSError *JSONError;
				JSONData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
				if (!JSONData) {
					NSLog(@"Error parsing JSON: %@.", JSONError);
					importSucceeded = NO;
				}
				NSAssert([JSONData isKindOfClass:[NSArray class]], @"Wrong type returned as the top level JSON object.");
				
			}
			
			if (importSucceeded) {
				
				// Brute force JSON importing.
				
				NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
				moc.parentContext = self.managedObjectContext;
				
				[moc performBlockAndWait:^{

					for (NSDictionary *cityDictionary in JSONData) {
						
						City *city = [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:moc];
						city.name = [cityDictionary objectForKey:@"name"];
						city.mapFile = [cityDictionary objectForKey:@"mapFile"];
						
						NSMutableDictionary *POIsByName = [NSMutableDictionary new];
						
						NSArray *POIArray = [cityDictionary objectForKey:@"pois"];
						
						for (NSDictionary *poiDictionary in POIArray) {

							POI *poi = [NSEntityDescription insertNewObjectForEntityForName:@"POI" inManagedObjectContext:moc];
							poi.name = [poiDictionary objectForKey:@"name"];
							poi.text = [poiDictionary objectForKey:@"text"];
							
							NSString *pointString = [poiDictionary objectForKey:@"mapPoint"];
							NSAssert(!CGPointEqualToPoint(CGPointFromString(pointString), CGPointZero), @"Could not parse mapPoint");
							poi.mapPoint = pointString;
							
							poi.latitude = [poiDictionary objectForKey:@"latitude"];
							poi.longitude = [poiDictionary objectForKey:@"longitude"];
							
							[city addPoisObject:poi];
							
							[POIsByName setObject:poi forKey:poi.name];
							
						}
						
						NSArray *tourArray = [cityDictionary objectForKey:@"tours"];
						
						for (NSDictionary *tourDictionary in tourArray) {
							
							Tour *tour = [NSEntityDescription insertNewObjectForEntityForName:@"Tour" inManagedObjectContext:moc];
							tour.name = [tourDictionary objectForKey:@"name"];
							
							NSArray *POIs = [tourDictionary objectForKey:@"pois"];
							for (NSString *POIName in POIs) {
	
								POI *currentPOI = [POIsByName objectForKey:POIName];
								[tour addPoisObject:currentPOI];
	
							}
							
						}
						
					}
					
					NSError *saveError;
					BOOL saved = [moc save:&saveError];
					if (!saved) {
					
						NSLog(@"Error saving after the data import");
						importSucceeded = NO;
					
					} else {
						
						// We made it!
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:CIVODataImportedUserDefaultsKey];

						NSManagedObjectContext *parentMOC = [moc parentContext];
						[parentMOC performBlock:^{
							
							NSError *parentSaveError;
							BOOL parentSaved = [parentMOC save:&parentSaveError];
							if (!parentSaved) {
								NSLog(@"Error saving data. %@", parentSaveError);
							}
							
						}];
					}
					
					
				}];
				
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[MBProgressHUD hideHUDForView:self.window animated:YES];
				
				if (!importSucceeded) {
					
					NSString *importErrorMessage = NSLocalizedString(@"There was a problem importing the data. Please contact your friendly neighborhood support team.", nil);
					NSString *OKButtonTitle = NSLocalizedString(@"OK", @"Title for an OK button");
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:importErrorMessage delegate:nil cancelButtonTitle:OKButtonTitle otherButtonTitles:nil];
					[alert show];

				}
				
			});
			
			
		});
	}
							
}

@end
