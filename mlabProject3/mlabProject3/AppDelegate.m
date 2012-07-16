//
//  AppDelegate.m
//  mlabProject3
//
//  Created by Abhijeet Mulay on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Patient.h"

@implementation AppDelegate
@synthesize tabBarController = _tabBarController;
@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize splitViewController = _splitViewController;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [patientsDict release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    patientsDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"logged_cardiac_data_1",@"Jennifer",@"Rahul",@"Sam",@"rajib",@"John",@"logged_cardiac_data_1",@"Christopher",@"logged_cardiac_data_1",@"Sylvia" ,nil];
    //[self setupData];
                   
    /***********************************************************************
     * TabBar Views (unused)
     **********************************************************************/
    
    UIViewController *viewController1 = [[[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil] autorelease];
    //UIViewController *viewController2 = [[[SecondViewController alloc] initWithNibName:@"SecondViewController" bundle:nil] autorelease];
     
        
    
    /***********************************************************************
     * SplitView Views 
     **********************************************************************/  
    
    MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil] autorelease];
    UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
    
    
    //UI Customisation...
    
    // [masterNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBarBG.png"] forBarMetrics:UIBarMetricsDefault];
    //[masterNavigationController.navigationBar setTintColor:[UIColor colorWithRed:<#(CGFloat)#> green:<#(CGFloat)#> blue:<#(CGFloat)#> alpha:<#(CGFloat)#>]];
    
    DetailViewController *detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil] autorelease];
    UINavigationController *detailNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailViewController] autorelease];
    
    // [detailNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"DetailBarBG.png"] forBarMetrics:UIBarMetricsDefault];
    //[detailNavigationController.navigationBar setTintColor:[UIColor lightGrayColor]];
    
    self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
    self.splitViewController.delegate = detailViewController;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
    masterViewController.detailViewController = detailViewController;
    
    /***********************************************************************
     * Tab Bar Controller 
     **********************************************************************/  
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.tabBar.tintColor = [UIColor grayColor];
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects: /*viewController2*/self.splitViewController,/*viewController1,*/ nil];
    [[[self.tabBarController.tabBar items] objectAtIndex:0] setTitle:@"Patients"];
    [[[self.tabBarController.tabBar items] objectAtIndex:0] setImage:[UIImage imageNamed:@"first.png"]];
    //[self.tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"tabBarBG.png"]];
    [self.tabBarController.tabBar setTintColor:[UIColor clearColor]];
    self.window.rootViewController = self.tabBarController;
    //[self.window addSubview:self.tabBarController.view];
    [self.window makeKeyAndVisible];
    return YES;
}


/*************************************************************************************
 * Setup Dummy Data....Trying out Core Data (to be used for further implementation...)
 ***************************************************************************************/ 

- (void)setupData
{
    NSArray *fileNames = [patientsDict allValues]; 
    NSArray *names = [patientsDict allKeys]; 
    NSManagedObjectContext *context = [self managedObjectContext];
    for (int i = 0; i < [patientsDict count]; i++) {
        Patient *patient = [NSEntityDescription
                                          insertNewObjectForEntityForName:@"Patient" 
                                          inManagedObjectContext:context];
        patient.name = [names objectAtIndex:i];
        patient.fileName = [fileNames objectAtIndex:i];
        NSError *error;
        if (![context save:&error])
        {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
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
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"mlabProject3" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"mlabProject3.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
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
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
