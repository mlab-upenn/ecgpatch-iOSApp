//
//  AppDelegate.h
//  mlabProject3
//
//  Created by Abhijeet Mulay on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "SecondViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{
     NSMutableDictionary *patientsDict; //dummy patients dictionary, to be used for device names
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UISplitViewController *splitViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)setupData;
@end
