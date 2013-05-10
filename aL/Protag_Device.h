#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Alarm.h"
@class NotificationGrouper;//circular dependency, used this to fix

extern int const RSSI_DISTANCE[];

typedef enum {
    STATUS_CONNECTED,
    STATUS_NOT_CONNECTED,
    STATUS_CONNECTION_FAILED,
    STATUS_CONNECTING,
    STATUS_DISCONNECTING,
    STATUS_DISCONNECTED,
    STATUS_SNOOZE,
    STATUS_LOST
} DeviceStatus;

@interface Protag_Device : NSObject<AlarmContainer,UIAlertViewDelegate>{
    CBPeripheral *_peripheral;
    bool bol_initialized;
}

@property (nonatomic) NSString *str_Name;
@property (nonatomic) NSString *str_DateLost;
@property (nonatomic) NSString *str_UUID;
@property (nonatomic) int int_Icon;
@property (nonatomic) int int_Battery;
@property (nonatomic) double _longitude;
@property (nonatomic) double _latitude;
@property (nonatomic) NotificationGrouper *_Notification;
@property (nonatomic) NSString *str_Status;
@property (nonatomic) int int_Status;
@property (nonatomic) int index_Distance;
@property (nonatomic) int SnoozeSeconds;
@property (nonatomic) int int_RSSI;
@property (nonatomic) NSTimer *_timerConnectionFailed;

-(id)init_WithPeripheral:(CBPeripheral*) peripheral;
//-(id)init_WithDummyValues;
-(void)set_Status:(DeviceStatus)status;
-(int)get_StatusCode;
-(BOOL)identicalToPeripheral:(CBPeripheral*) peripheral;
-(BOOL)isEqualUUID:(CBPeripheral*) peripheral;

-(void)Set_Peripheral:(CBPeripheral*) peripheral;
-(void)Connect;
-(void)Connection_Failed;
-(void)Disconnect;
-(BOOL)isConnected;
-(int)get_RSSI;
-(int)get_PhoneRSSI;
-(void)update_RSSI:(int)RSSI;
-(void)update_Battery:(int)Battery;
-(double)RSSItoDistance;
-(void)UpdateSnoozeStatus;
-(void)DismissSnooze;
-(void)UpdateLostInformation;
-(void)UnscheduleNotification;
-(void)RegrabPeripheral;
-(void)toggleSpeedUp;

@end
