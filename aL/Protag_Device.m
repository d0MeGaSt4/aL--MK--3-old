#import "Protag_Device.h"
#import "BluetoothController.h"
#import "DeviceController.h"
#import "NotificationGrouper.h"
#import "GPSController.h"
#import "Alarm.h"

NSString * const KEY_NAME = @"KEY_NAME";
NSString * const KEY_DATELOST = @"KEY_DATELOST";
NSString * const KEY_UUID = @"KEY_UUID";
NSString * const KEY_LONGITUDE = @"KEY_LONGITUDE";
NSString * const KEY_LATITUDE = @"KEY_LATITUDE";
NSString * const KEY_ICON = @"KEY_ICON";
NSString * const KEY_DISTANCE = @"KEY_DISTANCE";


//Modify the RSSI limit here
int const TESTED_MAX_RSSI = 0;
int const TESTED_MIN_RSSI = -255;
int const RSSI_DISTANCE[] = {TESTED_MAX_RSSI-15,((TESTED_MAX_RSSI-TESTED_MIN_RSSI)/2)+TESTED_MIN_RSSI,TESTED_MIN_RSSI};


@implementation Protag_Device

@synthesize str_Name;
@synthesize str_DateLost;
@synthesize str_Status;
@synthesize str_UUID;
@synthesize _longitude;
@synthesize _latitude;
@synthesize index_Distance;
@synthesize int_Battery;
@synthesize int_Status;
@synthesize int_Icon;
@synthesize SnoozeSeconds;
@synthesize _Notification;
@synthesize int_RSSI;
@synthesize _timerConnectionFailed;


-(id)init_WithPeripheral:(CBPeripheral *)peripheral{
    if(self = [super init]){
        bol_initialized = FALSE;
        _peripheral = peripheral;
        [_peripheral setDelegate:[BluetoothController sharedInstance]];
        str_Name = peripheral.name;
        str_UUID = (__bridge NSString*)CFUUIDCreateString(nil,peripheral.UUID);
        [self set_Status:STATUS_NOT_CONNECTED];
        str_DateLost=@"";
        int_Battery = 0;
        int_Icon = 0;
        index_Distance = 2; //default RSSI distance index
        SnoozeSeconds = 0;
        int_RSSI = INT_MIN;
        _Notification = NULL;
        _timerConnectionFailed = NULL;
        bol_initialized = TRUE;
    }
    return self;
}

/*-(id)init_WithDummyValues{
    if(self = [super init]){
        bol_initialized=false;
        _peripheral = NULL;
        str_Name = @"Dummy";
        str_UUID = @"123456789";
        [self set_Status:STATUS_NOT_CONNECTED];
        str_DateLost=@"";
        int_Icon = 0;
        int_Battery = 0;
        index_Distance = 2; //default RSSI distance index
        SnoozeSeconds = 0;
        bol_initialized=true;
        int_RSSI = INT_MIN;
    }
    return self;
}*/

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    //Used for DataController to save
	[encoder encodeObject:self.str_Name forKey:KEY_NAME];
    [encoder encodeObject:self.str_UUID forKey:KEY_UUID];
    [encoder encodeObject:self.str_DateLost forKey:KEY_DATELOST];
    [encoder encodeDouble:_longitude forKey:KEY_LONGITUDE];
    [encoder encodeDouble:_latitude forKey:KEY_LATITUDE];
    [encoder encodeInt:index_Distance forKey:KEY_DISTANCE];
    [encoder encodeInt:int_Icon forKey:KEY_ICON];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        bol_initialized=false;
        //decode properties, other class vars
        _peripheral=NULL; //peripheral update done by DeviceController
        str_Name = [decoder decodeObjectForKey:KEY_NAME];
        str_UUID = [decoder decodeObjectForKey:KEY_UUID];
        str_DateLost = [decoder decodeObjectForKey:KEY_DATELOST];
        _longitude = [decoder decodeDoubleForKey:KEY_LONGITUDE];
        _latitude = [decoder decodeDoubleForKey:KEY_LATITUDE];
        index_Distance = [decoder decodeIntForKey:KEY_DISTANCE];
        int_Icon = [decoder decodeIntForKey:KEY_ICON];
        [self set_Status:STATUS_NOT_CONNECTED];
        _Notification=NULL;
        _timerConnectionFailed=NULL;
        bol_initialized=true;
    }
    return self;
}

-(void)set_Status:(DeviceStatus)status{
    int_Status = status;
    NSLog(@"Setting Status for %@: %d",str_Name,int_Status);
    switch (status) {
        case STATUS_SNOOZE:
            str_Status=@"Connecting in...";
            [self UpdateSnoozeStatus];
            break;
        //All other status reset SnoozeSeconds back to 0
        SnoozeSeconds=0;
        case STATUS_CONNECTED:
            str_Status=@"Connected";
            break;
        case STATUS_CONNECTING:
            str_Status=@"Connecting...";
            break;
        case STATUS_DISCONNECTED:
            str_Status=@"Disconnected";
            break;
        case STATUS_DISCONNECTING:
            str_Status=@"Disconnecting...";
            break;
        case STATUS_LOST:
            str_Status=@"Unsecured";
            [self UnscheduleNotification];
            break;
        case STATUS_NOT_CONNECTED:
            str_Status=@"Not Connected";
            break;
        case STATUS_CONNECTION_FAILED:
            str_Status=@"Connection Failed";
            break;
        default:
            str_Status=@"UNKNOWN STATUS CODE";
            break;
    }
    if(bol_initialized == TRUE)
        [[DeviceController sharedInstance]RefreshDeviceTable];
}

-(int)get_StatusCode{
    return int_Status;
}

-(void)Connect{
    NSLog(@"Connect %@",str_Name);
    if(_peripheral!=NULL)
    {
        if (![_peripheral isConnected])
        {
            [self set_Status:STATUS_CONNECTING];
            [[[BluetoothController sharedInstance]CentralManager] connectPeripheral:_peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
            if(_timerConnectionFailed==NULL){
             _timerConnectionFailed = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(Connection_Failed) userInfo:nil repeats:false];
            }
        }
    }
    else{
        NSLog(@"%@ has empty Peripheral",str_Name);
        [self RegrabPeripheral];
    }
}

-(void)Disconnect{
    NSLog(@"Disconnect %@",str_Name);
    if(_peripheral!=NULL)
    {
        if ([_peripheral isConnected])
        {
            [self set_Status:STATUS_DISCONNECTING];
            if(_timerConnectionFailed!=NULL)
            {
                [_timerConnectionFailed invalidate];
                _timerConnectionFailed = NULL;
            }
            [[[BluetoothController sharedInstance]CentralManager] cancelPeripheralConnection:_peripheral];
        }
    }
    else{
        NSLog(@"%@ has empty Peripheral",str_Name);
        [self RegrabPeripheral];
    }
}

-(void)Connection_Failed{
    if(_timerConnectionFailed!=NULL)
    {
        [_timerConnectionFailed invalidate];
        _timerConnectionFailed = NULL;
    }
    
    Alarm *alarm = [[Alarm alloc]init];
    if(_peripheral!=NULL && ![_peripheral isConnected])
    {
        NSLog(@"Connection Failed %@",str_Name);
        bol_initialized = TRUE;
       
        if(![[[DeviceController sharedInstance]_LostDevices]containsObject:self])
        {
            //If was not connected before hand
            if(int_Status == STATUS_CONNECTING)
            {
                UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Device Status" message:[NSString stringWithFormat:@"Connection Fails with Protag"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [message show];
                AudioServicesPlayAlertSound(1022);
            }
            NSLog(@"%@,%d",str_Status,int_Status);
            [self set_Status:STATUS_CONNECTION_FAILED];
            if([alarm isInBackground])
                [alarm ShowLocalNotification];
       }
       else
       {
            [[DeviceController sharedInstance]Add_LostDevice:self];//it will not add, it will just cause it to ring the alarm
       }
       [[[BluetoothController sharedInstance]CentralManager] cancelPeripheralConnection:_peripheral];
    }
}


//This RSSI is from Protag
-(int)get_RSSI{
    return int_RSSI;
}


//This RSSI is from Phone
-(int)get_PhoneRSSI{
    if([_peripheral isConnected])
    {
        [_peripheral readRSSI];
        return _peripheral.RSSI.intValue;
    }
    return INT_MIN;
}

-(double)RSSItoDistance{
    double double_EstimatedMaxDistance = 8;// in meters

    double double_RSSItoDistanceFactor = double_EstimatedMaxDistance/(TESTED_MAX_RSSI-TESTED_MIN_RSSI);
    if(int_RSSI!=INT_MIN){
        double tempDouble = (TESTED_MAX_RSSI-int_RSSI)*double_RSSItoDistanceFactor;
        if(tempDouble>0)
            return tempDouble;
        else
            return 0;
    }
    else
        return 0;
}

-(void)update_RSSI:(int)RSSI{
    int_RSSI = RSSI;
        
    [[DeviceController sharedInstance]RefreshDeviceTable];
    
    //Stronger RSSI means closer
    if(int_RSSI!=INT_MIN &&
       int_RSSI<RSSI_DISTANCE[index_Distance]){
        NSLog(@"RSSI is lesser than the set Distance, adding to lost device");
        
        //if RSSI is lesser than preset RSSI distance, it would mean that  it is further away from the indicated distance
        [self Disconnect];
        [[DeviceController sharedInstance]Add_LostDevice:self];
    }
}

-(void)update_Battery:(int)Battery{
    int_Battery = Battery;
    [[DeviceController sharedInstance]RefreshDeviceTable];
}

-(void)Set_Peripheral:(CBPeripheral*) peripheral{
    if([self isEqualUUID:peripheral])
        _peripheral = peripheral;
    else
        NSLog(@"Tried to set a peripheral with a different UUID");
}

-(BOOL)isEqualUUID:(CBPeripheral*) peripheral{
    return [str_UUID isEqualToString:(__bridge NSString*)CFUUIDCreateString(nil,peripheral.UUID)];
}

-(BOOL)identicalToPeripheral:(CBPeripheral*) peripheral{
    if(_peripheral!=NULL && ([_peripheral isEqual:peripheral] || [self isEqualUUID:peripheral]))
        return true;
    else
        return false;
}

-(BOOL)isConnected{
    if(_peripheral==NULL)
        return false;
    else
        return [_peripheral isConnected];
}


#pragma AlarmContainer functions
////////////////////////////////////////////////////////////////////////

-(void)Set_Minutes:(int)minutes
{
    //Alarm sets minutes after this device is pushed into Lost Devices
    //This function used for user to set snooze timing
    if(minutes>0)
    {
        SnoozeSeconds=minutes*60;
        [self set_Status:STATUS_SNOOZE];
        NSLog(@"Set_Minutes in Seconds: %i",SnoozeSeconds);
    }
}

//used by NStimer to reduce (does not work in background)
-(void)reduce_Second{
    //Reduced by Alarm
    if(SnoozeSeconds>0)
        SnoozeSeconds--;
    else
        [self UnscheduleNotification];
    [self UpdateSnoozeStatus];
    
    //Ringing of alarm when this is 0 is checked by Alarm, not this device
}

//only used when app comes from background to active
-(void)reduce_Seconds:(int)seconds{
    if(int_Status==STATUS_SNOOZE)
    {
        NSLog(@"reduce_seconds %d",seconds);
        SnoozeSeconds = SnoozeSeconds-seconds;
        if(SnoozeSeconds<=0)
        {
            SnoozeSeconds=0;
            [self UnscheduleNotification];
        }
        [self UpdateSnoozeStatus];
    }
}


#pragma End of AlarmContainer Methods
/////////////////////////////////////////////////////////////////////////


-(void)UpdateSnoozeStatus{
    if(int_Status==STATUS_SNOOZE)
    {
        str_Status=@"Connecting in ";
        int seconds = SnoozeSeconds%60;
        int totalminutes = SnoozeSeconds/60;
        int hours = totalminutes/60;
        int minutes = totalminutes%60;
        
        if(hours>0)
            str_Status=[NSString stringWithFormat:@"%@%ih ",str_Status,hours];
        if(minutes>0)
            str_Status=[NSString stringWithFormat:@"%@%im ",str_Status,minutes];
        if(seconds>0)
            str_Status=[NSString stringWithFormat:@"%@%is",str_Status,seconds];
        
        str_Status=[NSString stringWithFormat:@"%@...",str_Status];
        
        [[DeviceController sharedInstance]RefreshDeviceTable];
    }
}

-(void)DismissSnooze{
    //attempt to reconnect again
    if(int_Status == STATUS_SNOOZE)
    {
        [[[DeviceController sharedInstance]_LostDevices]removeObject:self];
        [self set_Status:STATUS_LOST];
    }
}

-(void)UpdateLostInformation{
    NSLog(@"%@ updating lost information",str_Name);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterLongStyle];
    [self setStr_DateLost:[formatter stringFromDate:[NSDate date]]];
    [[GPSController sharedInstance]queue_for_update_Location:self];
}

-(void)UnscheduleNotification{
    if(_Notification!=NULL)
    {
        NSLog(@"%@ UnscheduleNotification",str_Name);
        [_Notification Unschedule];
        _Notification=NULL;
    }
}

-(void)RegrabPeripheral{
    NSMutableArray* _UUIDList = [[NSMutableArray alloc]init];
    //Link with UUID with peripheral
    CFUUIDRef CFUUID = CFUUIDCreateFromString(NULL,(__bridge CFStringRef)str_UUID);
    [_UUIDList addObject:(__bridge id)CFUUID];
    //Retrieve the existing peripherals, task delegated to BluetoothController
    //BluetoothController will link peripheral with the devices in memory
    [[BluetoothController sharedInstance]get_Peripherals:_UUIDList];
}

-(void)toggleSpeedUp{
    [[BluetoothController sharedInstance]SpeedupUpdates:_peripheral];
}

@end
