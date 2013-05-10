//This class is used by Protag_Device to update Location

#import "GPSController.h"
#import "DeviceController.h"
#import "WarningController.h"

@implementation GPSController

//Singleton
+(id)sharedInstance{
    static GPSController *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [super init];
    if(self)
    {
        //Initialize
        _LocationManager = [[CLLocationManager alloc] init];
        [_LocationManager setDelegate:self];
        [_LocationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
        _DeviceList = [[NSMutableArray alloc]init];
        
        [self CheckGPSStatus];
    }
    return self;
}

-(void)queue_for_update_Location:(Protag_Device *)device{
    if(![_DeviceList containsObject:device])
       [_DeviceList addObject:device];

    if(_DeviceList.count>0)
        [_LocationManager startUpdatingLocation];
}

#pragma CLLocationManagerDelegate functions

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //WARNING: THIS IS ONLY USED FOR iOS6 AND ABOVE
    //Updated Location
    //Most recent location is the last in the NSArray, API says will always have a size of at least 1
    NSLog(@"Updated Location, iOS6+");
    [self UpdateDevices:[locations objectAtIndex:locations.count-1]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    //WARNING: THIS IS ONLY USED FOR iOS5 AND BELOW
    NSLog(@"Updated Location iOS5-");
    [self UpdateDevices:newLocation];
}

-(void)UpdateDevices:(CLLocation*)location{
    //Sometimes the updates give 0,0 which should be discarded
    if([location coordinate].latitude==0 && [location coordinate].latitude==0){
        NSLog(@"Updated Coordinates invalid, retrying again");
        return;
    }
    
    [_LocationManager stopUpdatingLocation];
    while(_DeviceList.count>0)
    {
        Protag_Device *device = (Protag_Device*)[_DeviceList objectAtIndex:0];
        NSLog(@"GPSController updating %@ coordinates",device.str_Name);
        [device set_latitude:[location coordinate].latitude];
        [device set_longitude:[location coordinate].longitude];
        [_DeviceList removeObjectAtIndex:0];
    }
    [[DeviceController sharedInstance]RefreshDeviceTable];
}

-(void)CheckGPSStatus{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        [[WarningController sharedInstance]AlertEvent:GPS_ALLOWED];
        if([CLLocationManager locationServicesEnabled]==true)
            [[WarningController sharedInstance]AlertEvent:GPS_ON];
        else
            [[WarningController sharedInstance]AlertEvent:GPS_OFF];
    }
    else
        [[WarningController sharedInstance]AlertEvent:GPS_NOT_ALLOWED];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    //Fail
#warning to do
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        [[WarningController sharedInstance]AlertEvent:GPS_ALLOWED];
    else
        [[WarningController sharedInstance]AlertEvent:GPS_NOT_ALLOWED];
}

@end
