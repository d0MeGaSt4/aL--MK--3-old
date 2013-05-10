#import "DeviceController.h"
#import "DataController.h"
#import "BluetoothController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Protag_Device.h"
#import "Alarm.h"


#warning TODO music, snooze, characteristics.

@implementation DeviceController

@synthesize _currentDevices;
@synthesize _LostDevices;
@synthesize _ObserverList;
@synthesize _DetailsDevice;

//Singleton
+(id)sharedInstance{
    static DeviceController *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    if(self = [super init]){
        _ObserverList = [[NSMutableArray alloc]init];
        _currentDevices = [[DataController sharedInstance]load_Devices];
        _LostDevices = [[NSMutableArray alloc]init];
#warning for testing only, remove later
     /*   if([_currentDevices count]==0){
            [_currentDevices addObject: [[Protag_Device alloc]init_WithDummyValues]];
            [_currentDevices addObject: [[Protag_Device alloc]init_WithDummyValues]];
            [_currentDevices addObject: [[Protag_Device alloc]init_WithDummyValues]];
            [_currentDevices addObject: [[Protag_Device alloc]init_WithDummyValues]];
            [_currentDevices addObject: [[Protag_Device alloc]init_WithDummyValues]];
            [_currentDevices addObject: [[Protag_Device alloc]init_WithDummyValues]];
            [_currentDevices addObject: [[Protag_Device alloc]init_WithDummyValues]];
        }*/
        
        
        NSMutableArray* _UUIDList = [[NSMutableArray alloc]init];
        //Link with UUID with peripheral
        for(int i=0;i<_currentDevices.count;i++){
            Protag_Device *temp = (Protag_Device*)[_currentDevices objectAtIndex:i];
            //Add UUID to list
            CFUUIDRef CFUUID = CFUUIDCreateFromString(NULL,(__bridge CFStringRef)temp.str_UUID);
            [_UUIDList addObject:(__bridge id)CFUUID];
        }
        //Retrieve the existing peripherals, task delegated to BluetoothController
        //BluetoothController will link peripheral with the devices in memory
        [[BluetoothController sharedInstance]get_Peripherals:_UUIDList];
    }
    return self;
}

-(void)add_Device:(Protag_Device*)Device{
    //Allow only upto 7 device
    if(![_currentDevices containsObject:Device] && _currentDevices.count<7)
    {
        [_currentDevices addObject:Device];
        [self RefreshDeviceTable];
    }
}
-(void)remove_Device:(Protag_Device*)Device{
    if([_currentDevices containsObject:Device])
    {
        [Device Disconnect];
        [_currentDevices removeObject:Device];
        if(Device == _DetailsDevice)
            _DetailsDevice = NULL;
        if([_LostDevices containsObject:Device])
            [_LostDevices removeObject:Device];
        
        [[DataController sharedInstance]save_Devices];
        [self RefreshDeviceTable];
    }
}

-(void)update_Device_Status:(CBPeripheral*)peripheral withStatus:(int)Status;{
    for(int i=0;i<_currentDevices.count;i++){
        Protag_Device *device = [_currentDevices objectAtIndex:i];
        if([device identicalToPeripheral:peripheral])
        {
            [device set_Status:Status];
            break;
        }
    }
    [self RefreshDeviceTable];
}

-(void)registerObserver:(id<DeviceObserver>) Observer{
    if(![_ObserverList containsObject:Observer])
        [_ObserverList addObject:Observer];
}

-(void)deregisterObserver:(id<DeviceObserver>) Observer{
    if([_ObserverList containsObject:Observer])
        [_ObserverList removeObject:Observer];
}

-(void)RefreshDeviceTable{
    for(int i=0;i<_ObserverList.count;i++)
    {
        [(id<DeviceObserver>)[_ObserverList objectAtIndex:i]RefreshDeviceTable];
    }
}

-(BOOL)has_Device_with_Peripheral:(CBPeripheral*)peripheral{
    Protag_Device *device = [self Device_With_Peripheral:peripheral];
    if(device!=NULL)
        return true;
    else 
        return false;
    return false;
}

-(Protag_Device*)Device_With_Peripheral:(CBPeripheral*)peripheral{
    for(int i=0;i<_currentDevices.count;i++){
        Protag_Device *device = [_currentDevices objectAtIndex:i];
        if([device identicalToPeripheral:peripheral])
            return device;
    }
    return NULL;
}

-(void)Clear_LostDevices{
    NSLog(@"Clearing Lost Device List");
#warning this will cause all the lost device to be cleared which is wrong. Should only clear those with 0 snoozeTimer
    while(_LostDevices.count>0)
    {
        Protag_Device *device = (Protag_Device*)[_LostDevices objectAtIndex:0];
        [device Disconnect];
        [device set_Status:STATUS_LOST];
        [_LostDevices removeObjectAtIndex:0];
    }

    [self RefreshDeviceTable];
}

-(void)Add_LostDevice:(Protag_Device*)_Device{
    if(![_LostDevices containsObject:_Device])
    {
        [_LostDevices addObject:_Device];
        [_Device UpdateLostInformation];
    }
    
    //Alarm will pull the lost Device names and update when neccessary
    [[Alarm sharedInstance]ShowAlert];
}

-(NSString*)LostDevice_Names{
    NSString *str_temp = @"";
    for(int i =0;i<_LostDevices.count;i++)
    {
        Protag_Device *device = [_LostDevices objectAtIndex:i];
        if(device.SnoozeSeconds==0)
            str_temp = [NSString stringWithFormat:@"%@%@ ",str_temp,[device str_Name]] ;
    }
    return str_temp;
}



@end
