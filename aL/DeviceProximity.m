#import "DeviceProximity.h"
#import "BluetoothController.h"

@implementation DeviceProximity

-(id)init{
    self = [super init];
    if(self){
        _ObserverList = [[NSMutableArray alloc]init];
        double_updateInterval=1.5;
        int_proximityCount=0;
        _device = NULL;
        _timer = NULL;
    }
    return self;
}

-(void)registerObserver:(id<ProximityObserver>)observer{
    if(![_ObserverList containsObject:observer])
       [_ObserverList addObject:observer];
    
}
-(void)deregisterObserver:(id<ProximityObserver>)observer{
    [_ObserverList removeObject:observer];
}

-(void)startScanning:(Protag_Device*)device{
    int_proximityCount = 0;
    _device = device;
    
    //Initialize proximity bluetooth
    [[BluetoothController sharedInstance]set_proximityDevice:device];
    [[BluetoothController sharedInstance]set_proximitydelegate:self];
    
    if(_timer==NULL)
        _timer = [NSTimer scheduledTimerWithTimeInterval:double_updateInterval target:self selector:@selector(UpdateObservers) userInfo:nil repeats:true];
}

-(void)stopScanning{
    _device = NULL;
    if(_timer!=NULL)
    {
        [_timer invalidate];
        _timer = NULL;
    }
    
    //Tear down proximity bluetooth
    [[BluetoothController sharedInstance]stopScanning];
    [[BluetoothController sharedInstance]set_proximityDevice:NULL];
    [[BluetoothController sharedInstance]set_proximitydelegate:NULL];
}

-(void)detectedProximityDevice:(Protag_Device*)device withRSSI:(int)RSSI{
    int_proximityCount=0;
    NSLog(@"Proximity Long Range");
    [self UpdateObserverStatus:PROXIMITY_LONG_RANGE];
    if(device.int_Status!=STATUS_CONNECTING && device.int_Status!=STATUS_CONNECTED){
        if([[BluetoothController sharedInstance]is_Scanning]==true)
            [[BluetoothController sharedInstance]stopScanning];
        [device Connect];
    }
}

-(void)UpdateObservers{
    if(_device==NULL)
        return;
    
    [self checkIfRequireScanning];
    
    if([_device isConnected]){
        NSLog(@"Proximity In Range");
        [self UpdateObserverStatus:PROXIMITY_IN_RANGE];
        [self UpdateObserverRSSI: [_device get_RSSI]];
        int_proximityCount=0;
    }
    
    if(int_proximityCount<=8)
        int_proximityCount++;
    else{
        NSLog(@"Proximity Not In Range");
        [self UpdateObserverStatus:PROXIMITY_NOT_IN_RANGE];
    }
}

-(void)checkIfRequireScanning{
    if(![_device isConnected] && [_device get_StatusCode]!=STATUS_CONNECTING && ![[BluetoothController sharedInstance]is_Scanning])
        [[BluetoothController sharedInstance]startScanning];
    else if([[BluetoothController sharedInstance]is_Scanning]==true)
        [[BluetoothController sharedInstance]stopScanning];
}


-(void)UpdateObserverRSSI:(int)RSSI{
    for(int i=0;i<_ObserverList.count;i++)
        [(id<ProximityObserver>)[_ObserverList objectAtIndex:i]UpdateRSSI:RSSI];
}

-(void)UpdateObserverStatus:(ProximityStatus)status{
    for(int i=0;i<_ObserverList.count;i++)
        [(id<ProximityObserver>)[_ObserverList objectAtIndex:i]UpdateStatus:status];
}

@end
