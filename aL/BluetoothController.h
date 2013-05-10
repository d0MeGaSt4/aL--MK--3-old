#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceProximity.h"

typedef enum {
    DISCOVERING_DEVICES,
    DISCOVERED_DEVICE,
    CONNECTING_DEVICE,
    CONNECTED_DEVICE,
    FAIL_CONNECT_DEVICE
}DiscoveryEvents;

//Protocol for viewcontroller to use so that we can display messages accordingly
@protocol DiscoveryObserver <NSObject>
- (void) AlertEvent:(DiscoveryEvents)event;
@end


@interface BluetoothController : NSObject<ProximityBluetooth>{
    CBCentralManager *_CentralManager;
    NSMutableArray *_Discovered_Peripherals;
    bool bol_Scanning;
}


@property (nonatomic, assign) id<DiscoveryObserver> _discoveryObserver;
@property (nonatomic,readonly) CBCentralManager *CentralManager;
@property (nonatomic,readonly) NSMutableArray *Discovered_Peripherals;
@property (nonatomic)UILocalNotification *_localNotification;
@property (nonatomic) CBCharacteristic *_speedUpCharacteristic;

+(id)sharedInstance;//Singleton
-(bool)is_BluetoothOn;
-(bool)is_BluetoothSupported;
-(bool)is_BluetoothAuthorized;
-(void)get_Peripherals:(NSArray*) UUID_List;
-(void)CheckBluetoothStatus;
-(bool)is_Scanning;
-(BOOL)isBluetoothBackground;
-(void)ShowBluetoothLocalNotification;
-(void) startScanning;
-(void) stopScanning;
-(void)SpeedupUpdates:(CBPeripheral*) peripheral; //speedsup or slowsdown 3s or 1s

@end
