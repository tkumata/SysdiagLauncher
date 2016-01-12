//
//  AppDelegate.h
//  Sysdiag Launcher
//
//  Created by KUMATA Tomokatsu on 7/25/15.
//  Copyright © 2015 KUMATA Tomokatsu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

