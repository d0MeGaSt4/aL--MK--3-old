#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Protag_Device.h"

@interface GPSController : NSObject<CLLocationManagerDelegate>{
    NSMutableArray *_DeviceList;
    CLLocationManager *_LocationManager;
}

+(id)sharedInstance;//Singleton
-(void)queue_for_update_Location:(Protag_Device*)device;
-(void)UpdateDevices:(CLLocation*)location;
-(void)CheckGPSStatus;

@end
