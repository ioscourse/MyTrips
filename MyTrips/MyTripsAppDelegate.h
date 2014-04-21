//
//  MyTripsAppDelegate.h
//  MyTrips
//
//  Created by Charles Konkol on 4/20/14.
//  Copyright (c) 2014 Rock Valley College. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTripsAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
