#import "BluetoothController.h"
#import "DeviceController.h"
#import "Protag_Device.h"
#import "Alarm.h"
#import "WarningController.h"
#import "NotificationGrouper.h"
#import "ViewController_DeviceDetails.h"
#import "RingtoneController.h"


//internal interface that only self can see
@interface BluetoothController () <CBCentralManagerDelegate, CBPeripheralDelegate>
@end


@implementation BluetoothController

@synthesize CentralManager = _CentralManager;
@synthesize Discovered_Peripherals = _Discovered_Peripherals;
@synthesize _discoveryObserver;

//Proximity
@synthesize _proximitydelegate;
@synthesize _proximityDevice;
@synthesize _localNotification;

@synthesize _speedUpCharacteristic;

//Singleton
+(id)sharedInstance{
    static BluetoothController *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    if(self = [super init]){
        _CentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        _Discovered_Peripherals = [[NSMutableArray alloc]init];
        _localNotification = [[UILocalNotification alloc]init];
        _speedUpCharacteristic = NULL;
        
        bol_Scanning = false;
        
        [self CheckBluetoothStatus];
    }
    return self;
}


-(bool)is_BluetoothOn{
    if(_CentralManager.state!=CBCentralManagerStatePoweredOff)
        return true;
    else
        return false;
}
-(bool)is_BluetoothSupported{
    if(_CentralManager.state==CBCentralManagerStateUnsupported)
        return false;
    else
        return true;
}
-(bool)is_BluetoothAuthorized{
    if(_CentralManager.state==CBCentralManagerStateUnauthorized)
        return false;
    else
        return true;
}

-(void)CheckBluetoothStatus{
    //Unorthodox way to enabling the popup that this application requires bluetooth access. It is showing up but not sure if this is the reason for it doing it
    [self startScanning];
    [self stopScanning];
    
    if(![self is_BluetoothSupported])
        [[WarningController sharedInstance]AlertEvent:BLUETOOTH_NOT_COMPATABLE];
    else
    {
        if([self is_BluetoothAuthorized])
        {
            [[WarningController sharedInstance]AlertEvent:BLUETOOTH_ALLOWED];
            if([self is_BluetoothOn])
                [[WarningController sharedInstance]AlertEvent:BLUETOOTH_ON];
            else
                [[WarningController sharedInstance]AlertEvent:BLUETOOTH_OFF];
        }
        else
            [[WarningController sharedInstance]AlertEvent:BLUETOOTH_NOT_ALLOWED];
    }
}

-(bool)is_Scanning{
    return bol_Scanning;
}

-(void)get_Peripherals:(NSArray*) UUID_List{
    [_CentralManager retrievePeripherals:UUID_List];
}


/****************************************************************************/
/*								Discovery                                   */
/****************************************************************************/
- (void) startScanning
{
    if(bol_Scanning==true)
        [self stopScanning];
    
    bol_Scanning = true;
    //NSArray			*uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
    NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    [_CentralManager scanForPeripheralsWithServices:[[NSArray alloc]initWithObjects:[CBUUID UUIDWithString:@"180f"], nil] options:options];
    

    [_discoveryObserver AlertEvent:DISCOVERING_DEVICES];
}


- (void) stopScanning
{
    [_CentralManager stopScan];
    bol_Scanning = false;
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //Discover peripheral add to discovery list
    Protag_Device *discovered_device = [[DeviceController sharedInstance]Device_With_Peripheral:peripheral];
    //only add to discovery if it is quite close to the phone
    //give the range 0 (closest) to -90 (furthest)
    if((int)RSSI > -30)
    {
        if (![_Discovered_Peripherals containsObject:peripheral] && discovered_device==NULL)
        {
            [peripheral setDelegate:self];
            [_Discovered_Peripherals addObject:peripheral];
            [_discoveryObserver AlertEvent:DISCOVERED_DEVICE];
        }
    }
    
    
    //Proximity detection
    if(discovered_device!=NULL && _proximitydelegate!=NULL && _proximityDevice!=NULL)
    {
        if([discovered_device isEqual:_proximityDevice])
        {
            NSLog(@"proximity device %@ with RSSI %@",discovered_device.str_Name,RSSI);
            [_proximitydelegate detectedProximityDevice:discovered_device withRSSI:(int)RSSI];
        }
    }
}



#pragma mark -
#pragma mark Connection/Disconnection
/****************************************************************************/
/*						Connection/Disconnection                            */
/****************************************************************************/

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //Remove peripheral from discovered peripheral
    if ([_Discovered_Peripherals containsObject:peripheral])
    {
        Protag_Device *_newDevice = [[Protag_Device alloc]init_WithPeripheral:peripheral];
        //Add to Maincontroller database
        [[DeviceController sharedInstance]add_Device: _newDevice];
        [_newDevice set_Status:STATUS_CONNECTED];
        [_Discovered_Peripherals removeObject:peripheral];
        //start discovering the services of connected peripheral
        [peripheral discoverServices:nil];
        
        //Alert Observer
        [_discoveryObserver AlertEvent:CONNECTED_DEVICE];
    }else if([[DeviceController sharedInstance]has_Device_with_Peripheral:peripheral])
    {
        //Scan for 180F services again to set the notify value of 2A19 to true
        [peripheral discoverServices:[[NSArray alloc]initWithObjects:[CBUUID UUIDWithString:@"180f"], nil]];
        //Update status : Connected
        [[DeviceController sharedInstance]update_Device_Status:peripheral withStatus: STATUS_CONNECTED];
    }else{
        //if not inside DeviceController list, disconnect from it
        [_CentralManager cancelPeripheralConnection:peripheral];
    }
    
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if ([_Discovered_Peripherals containsObject:peripheral])
    {
        [_discoveryObserver AlertEvent:FAIL_CONNECT_DEVICE];
        [_Discovered_Peripherals removeObject:peripheral];
    }
    else
        //Update status: Conection Failed
        [[DeviceController sharedInstance]update_Device_Status:peripheral withStatus: STATUS_CONNECTION_FAILED];
}


- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    Protag_Device *temp_Device = [[DeviceController sharedInstance]Device_With_Peripheral:peripheral];
    
    //This part used to detect device lost
    if(temp_Device!=NULL)
    {
        if([temp_Device get_StatusCode]==STATUS_CONNECTED)
        {
            //Add to lost device List, MainController will set the status for Protag_Device
            
            //Do not add to lost device if in proximity mode
#warning ask whether to ring if it was connected before the proximity mode
            if(!(_proximityDevice!=NULL && [temp_Device isEqual:_proximityDevice]))
            {
                NSLog(@"Peripheral disconnected, adding to lost device");
                [[DeviceController sharedInstance]Add_LostDevice:temp_Device];
            }
        }
        else if([temp_Device get_StatusCode]==STATUS_DISCONNECTING){
                [[DeviceController sharedInstance]update_Device_Status:peripheral withStatus: STATUS_DISCONNECTED];
        }
        else{
            NSLog(@"Unknown status code before disconnecting device: %@, %d",temp_Device.str_Name,[temp_Device get_StatusCode]);
        }
    }
    else{
        NSLog(@"temp_Device was NULL in disconnecting");
    }
    
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
    NSMutableArray *temp = [peripherals mutableCopy];
    NSMutableArray *_devices = [[DeviceController sharedInstance]_currentDevices];
    Boolean bol_PeripheralFound = false;
    
    //Find similar UUID
    for(int i=0;i<_devices.count;i++){
        Protag_Device *tempDevice = [_devices objectAtIndex:i];
        for(int k=0;k<temp.count;k++){
            CBPeripheral *tempPeripheral = (CBPeripheral*)[temp objectAtIndex:k];
            if([tempDevice isEqualUUID:tempPeripheral])
            {
                [tempDevice Set_Peripheral:tempPeripheral];
                [tempPeripheral setDelegate:self];
                //After remove object from temp, reduce the k
                [temp removeObjectAtIndex:k];
                k--;
                bol_PeripheralFound = true;
                NSLog(@"Found Peripheral for Protag Device: %@",tempDevice.str_Name);
                break;
            }
        }
        //if cannot find the UUID of such peripheral show Error
        if(bol_PeripheralFound==false){
            NSLog(@"Error: could not find peripheral for Protag Device : %@",tempDevice.str_Name);
        }
    }
}

- (void)clearDiscoveredDevices
{
    [_Discovered_Peripherals removeAllObjects];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    //state change when bluetooth on / off etc
    switch (central.state){
        case CBCentralManagerStatePoweredOff:
            [[WarningController sharedInstance]AlertEvent:BLUETOOTH_OFF];
            if([self isBluetoothBackground])
                [self ShowBluetoothLocalNotification];
            break;
        case CBCentralManagerStatePoweredOn:
            [[WarningController sharedInstance]AlertEvent:BLUETOOTH_ON];
            break;
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStateUnknown:
            [[WarningController sharedInstance]AlertEvent:BLUETOOTH_NOT_ALLOWED];
            break;
        case CBCentralManagerStateUnsupported:
            [[WarningController sharedInstance]AlertEvent:BLUETOOTH_NOT_COMPATABLE];
            break;
        default:
            return;
    }
}

/****************************************************************************/
/*                            CBPeripheralDelegate                          */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"Discovered Characteristics for service name: %@",(NSString*)service.UUID);
    for(int i=0;i<[service characteristics].count;i++)
    {
        CBCharacteristic *temp = [[service characteristics]objectAtIndex:i];
        NSLog(@"Characteristic UUID: %@ from %@",(NSString*)[temp UUID],(NSString*)service.UUID);
        
        [peripheral readValueForCharacteristic:temp];
        
        //UUID of characteristic 2A19 is used for Protag to send RSSI, battery level and for alerting the phone
        if([temp.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]])
        {
            [peripheral setNotifyValue:true forCharacteristic:temp];
            NSLog(@"Set notify value to true for 2A19");
        }
        
        if(_speedUpCharacteristic==NULL && [temp.UUID isEqual:[CBUUID UUIDWithString:@"2A3A"]]){
            _speedUpCharacteristic = temp;
            NSLog(@"Setting up _speedUpCharacteristic");
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //not using descriptor
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    //not used
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //180f is service for 2A19 characteristic
    NSLog(@"Discovered Services");
    for(int i=0;i<[peripheral services].count;i++)
    {
        CBService *temp_service = [[peripheral services]objectAtIndex:i];
        NSLog(@"Discovered Service UUID: %@",(NSString*)temp_service.UUID);
        [peripheral discoverCharacteristics:nil forService:temp_service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.value==NULL)
        return;
    
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]){
        
        //First we find the category of the information sent using the same channel
        uint8_t _CharacteristicCategory  = 0;
        [[characteristic value] getBytes:&_CharacteristicCategory length:sizeof (_CharacteristicCategory)];

        uint16_t positive16 =0;
        [[characteristic value] getBytes:&positive16 length:sizeof (positive16)];
        int16_t negative16 = 0;
        [[characteristic value] getBytes:&negative16 length:sizeof (negative16)];
        
        NSLog(@"Characteristic: %@ has a value of %@ and %x",characteristic.UUID,characteristic.value,positive16);
        
        Protag_Device *device = [[DeviceController sharedInstance]Device_With_Peripheral:peripheral];
        
        if(_CharacteristicCategory==0xfc){
            //For Protag to alert the phone
            //Protag_Device has pressed the ring phone button
            NSLog(@"Detected Ring Mobile Button");
            [[Alarm sharedInstance]ProtagAlertsPhone:device];
        }
        else if(_CharacteristicCategory==0xfd){
            //For RSSI readings from the Protag
            
            int ConvertedRSSI = negative16>>8;
            NSLog(@"Converted RSSI: %d",ConvertedRSSI);
            [device update_RSSI:ConvertedRSSI];//alerting the alarm to ring will be done by the device
        }
        else if(_CharacteristicCategory==0xfe){
            //For battery readings of the Protag
            int ConvertedBattery = positive16>>8;
            NSLog(@"Converted Battery Readings: %d",ConvertedBattery);
            [device update_Battery:ConvertedBattery];
        }
        else{
            NSLog(@"Unknown Characteristic category");
        }
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //not using descriptor
    //descriptors gave 0
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic==_speedUpCharacteristic)
        NSLog(@"write to speedup successful");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //not using descriptor
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}


//********************************************************
//Local Notification
//********************************************************

-(BOOL)isBluetoothBackground{
    return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}

-(void)ShowBluetoothLocalNotification{
    NSLog(@"Show Local Notification");
    //instant local notification
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    
    UILocalNotification *_LocalBluetoothNotification = [[UILocalNotification alloc]init];
    
    _LocalBluetoothNotification.alertBody = [NSString stringWithFormat:@"Bluetooth turned Off,Please turn On "];
    _LocalBluetoothNotification.alertAction = @"View";
    
    _LocalBluetoothNotification.soundName = [[RingtoneController sharedInstance]get_ToneFilename];
    _LocalBluetoothNotification.applicationIconBadgeNumber +=1;
    
    // Specify custom data for the notification
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
    _LocalBluetoothNotification.userInfo = infoDict;
    
    // Schedule the notification
    NSLog(@"scheduling notification grouper, Bluetooth On/Off device interval ");
    
    [[UIApplication sharedApplication] scheduleLocalNotification:_LocalBluetoothNotification];
    
    //Set devices as Lost
    if([[BluetoothController sharedInstance]is_BluetoothOn] == FALSE)
    {
        for(int i=0;i<[[DeviceController sharedInstance]_currentDevices].count;i++)
        {
            Protag_Device *device = (Protag_Device*)[[[DeviceController sharedInstance]_currentDevices]objectAtIndex:i];
            [[DeviceController sharedInstance]Add_LostDevice:device];
        }
    }
}

-(void)SpeedupUpdates:(CBPeripheral*) peripheral{
    if(_speedUpCharacteristic==NULL)
    {
        NSLog(@"_speedUpCharacteristic was NULL");
        return;
    }
    
    if(peripheral!=NULL){
        NSString *tempStr = @"ok";
        NSData *data = [tempStr dataUsingEncoding:NSUTF8StringEncoding];
        [peripheral writeValue:data forCharacteristic:_speedUpCharacteristic type:CBCharacteristicWriteWithResponse];
        NSLog(@"writing to speedup peripheral");
    }
}

@end
