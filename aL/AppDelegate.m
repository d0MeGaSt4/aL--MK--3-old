#import "AppDelegate.h"
#import "DataController.h"
#import "Alarm.h"
#import "GPSController.h"
#import "BluetoothController.h"
#import "ViewController_AddDevice.h"
#import "ViewController_DevicesWithSideMenu.h"
#import "ViewController_Settings.h"
#import "ViewController_UserManual.h"
#import "DeviceController.h"
#import "ViewController_DeviceDetails.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{        
    //Initialize non-view controllers so that they will check and respond with warnings
    [GPSController sharedInstance];
    [BluetoothController sharedInstance];
    //Loading of data done by DeviceController itself
    [DeviceController sharedInstance];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor darkGrayColor];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];

    //Home, mobile, device, help

        
    ViewController_DevicesWithSideMenu *GUIDevicesController = [[ViewController_DevicesWithSideMenu alloc]init];
    GUIDevicesController.tabBarItem.image = [UIImage imageNamed:@"home.png"];
    GUIDevicesController.tabBarItem.title = @"Home";
    UINavigationController *NavController_GUIDevices = [[UINavigationController alloc]initWithRootViewController:GUIDevicesController];
    
    ViewController_AddDevice *AddDeviceController = [[ViewController_AddDevice alloc]init];
    AddDeviceController.tabBarItem.image = [UIImage imageNamed:@"mobile.png"];
    AddDeviceController.tabBarItem.title = @"Mobile";
    UINavigationController *NavController_AddDevice = [[UINavigationController alloc]initWithRootViewController:AddDeviceController];
    
    
    ViewController_Settings *SettingsController = [[ViewController_Settings alloc]init];
    SettingsController.tabBarItem.image = [UIImage imageNamed:@"settings.png"];
    SettingsController.tabBarItem.title = @"Settings";
    UINavigationController *NavController_Settings = [[UINavigationController alloc]initWithRootViewController:SettingsController];
    
    ViewController_UserManual *UserManualController = [[ViewController_UserManual alloc]init];
    UserManualController.tabBarItem.image = [UIImage imageNamed:@"help.png"];
    UserManualController.tabBarItem.title = @"Help";
    UINavigationController *NavController_UserManual = [[UINavigationController alloc]initWithRootViewController:UserManualController];
    
    UITabBarController *TabbarController = [[UITabBarController alloc] init];
    
    [TabbarController setViewControllers:[NSArray arrayWithObjects:NavController_GUIDevices, NavController_AddDevice,NavController_Settings,NavController_UserManual, nil]];
    
    [self.window setRootViewController:TabbarController];
    
    [TabbarController.view setAutoresizesSubviews:true];
    
    TabbarController.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    
    NavController_AddDevice.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [NavController_AddDevice.view setAutoresizesSubviews:true];
    NavController_GUIDevices.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [NavController_GUIDevices.view setAutoresizesSubviews:true];
    
    NavController_Settings.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [NavController_Settings.view setAutoresizesSubviews:true];
    NavController_UserManual.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [NavController_UserManual.view setAutoresizesSubviews:true];
    
    //Show add Device page at the start if no devices added yet, else just show current Device tab
    if([[DeviceController sharedInstance]_currentDevices].count>0)
       [TabbarController setSelectedIndex:1];
    else
        [TabbarController setSelectedIndex:0];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[Alarm sharedInstance]PauseTimer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[DataController sharedInstance]save_Settings];
    [[DataController sharedInstance]save_Devices];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
 
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[BluetoothController sharedInstance] CheckBluetoothStatus];

    //BluetoothController *Bluetooth = [[BluetoothController alloc]init];
    //[Bluetooth CheckBluetoothStatus];
 }

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[Alarm sharedInstance]ResumeTimer];
    [[GPSController sharedInstance]CheckGPSStatus];
    [[BluetoothController sharedInstance]CheckBluetoothStatus];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[DataController sharedInstance]save_Devices];
    [[DataController sharedInstance]save_Settings];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
