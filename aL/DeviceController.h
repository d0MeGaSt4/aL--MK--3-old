#import <Foundation/Foundation.h>
#import "Protag_Device.h"

@protocol DeviceObserver <NSObject>
- (void) RefreshDeviceTable;
@end

@interface DeviceController : NSObject

@property (nonatomic,retain) NSMutableArray *_currentDevices;
@property (nonatomic,retain) NSMutableArray *_LostDevices;
@property (nonatomic,retain) NSMutableArray *_ObserverList;
@property (nonatomic, assign) Protag_Device *_DetailsDevice;



-(void)registerObserver:(id<DeviceObserver>) Observer;
-(void)deregisterObserver:(id<DeviceObserver>) Observer;
-(void)add_Device:(Protag_Device*)Device;
-(void)remove_Device:(Protag_Device*)Device;
-(void)update_Device_Status:(CBPeripheral*)peripheral withStatus:(int)Status;
-(BOOL)has_Device_with_Peripheral:(CBPeripheral*)peripheral;
-(Protag_Device*)Device_With_Peripheral:(CBPeripheral*)peripheral;
-(void)RefreshDeviceTable;
-(void)Clear_LostDevices;
-(void)Add_LostDevice:(Protag_Device*)_Device;
-(NSString*)LostDevice_Names;
+(id)sharedInstance; //Singleton

@end
