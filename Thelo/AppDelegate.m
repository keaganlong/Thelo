//
//  AppDelegate.m
//  Thelo
//
//  Created by Alex Stelea on 9/19/14.
//  Copyright (c) 2014 Alex Stelea. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIMutableUserNotificationAction *intentAction = [[UIMutableUserNotificationAction alloc] init];
    intentAction.identifier = @"intentAction";
    intentAction.title = @"I'm going!";
    intentAction.activationMode = UIUserNotificationActivationModeForeground;
    
    UIMutableUserNotificationCategory *intentCategory = [[UIMutableUserNotificationCategory alloc] init];
    [intentCategory setActions:@[intentAction] forContext:UIUserNotificationActionContextDefault];
    [intentCategory setActions:@[intentAction] forContext:UIUserNotificationActionContextMinimal];
    intentCategory.identifier = @"intentCategory";
    
    NSSet *categories = [NSSet setWithObjects:intentCategory, nil];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             categories:categories];
    [application registerUserNotificationSettings:settings];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        [LocationManager forceCheckOfRegions];
    }
    
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
    [LocationManager requestPermissions];
    [LocationManager startPeriodicUpdates];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    NSLog(@"AppDelegate - handleActionWithIdentifier: %@", identifier);
    if ([identifier isEqualToString:@"intentAction"]) {
        Event *event = [[Event alloc] init];
        event.eventID = [notification.userInfo objectForKey:@"event"];
        [APIHandler setIntentToAttendEvent:event withSuccessHandler:nil failureHandler:nil];
    }
    //must call completion handler when finished
    completionHandler();
}
//Called for remote notification action events
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    NSLog(@"AppDelegate - handleActionWithIdentifier: %@", identifier);
    
    //must call completion handler when finished
    completionHandler();
}

@end
