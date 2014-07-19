//
//  FlickrMapAppDelegate.m
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "FlickrMapAppDelegate.h"
#import "AuthWebViewController.h"
#import "FlickrAPI.h"

@implementation FlickrMapAppDelegate


@synthesize window=_window;

@synthesize navigationController=_navigationController;

// UIApplicationDelegateプロトコルで定義されているメソッド。アプリケーションが起動したときに呼び出される
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // 保存されている認証トークンとfrob文字列を取得
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *tokenData = [defaults objectForKey:@"tokenData"];
  NSString *frob = [defaults objectForKey:@"frob"];
  
  if (tokenData==nil || frob == nil) {
    // 認証トークンとfrob文字列が無いときは、アプリケーション認証用WEBページを表示
    AuthWebViewController *authWebViewController = [[AuthWebViewController alloc]initWithNibName:@"AuthWebViewController" bundle:nil];
    [self.navigationController pushViewController:authWebViewController animated:TRUE];
    [authWebViewController release];
  } else {
    // 認証トークンとfrob文字列をFlickrAPIインスタンスに設定
    FlickrAPI *flickrAPI = [FlickrAPI instance];
    [flickrAPI setTokenData:tokenData];
    [flickrAPI setFrob:frob];
  }
  self.window.rootViewController = self.navigationController;
  [self.window makeKeyAndVisible];
    return YES;
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
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
}

- (void)dealloc
{
  [_window release];
  [_navigationController release];
  [super dealloc];
}

@end
