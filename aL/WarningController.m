#import "WarningController.h"

@implementation WarningController

@synthesize _WarningList;

//Singleton
+(id)sharedInstance{
    static WarningController *_instance;
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
        _ObserverList = [[NSMutableArray alloc]init];
        _WarningList = [[NSMutableArray alloc]init];
        WARNING_BLUETOOTH_NOT_ALLOWED = @"Protag Elite does not have permission to access Bluetooth";
        WARNING_BLUETOOTH_OFF = @"Bluetooth is turned off";
        WARNING_GPS_NOT_ALLOWED = @"Protag Elite does not have permission to access GPS";
        WARNING_GPS_OFF = @"GPS is turned off";
        WARNING_BLUETOOTH_NOT_COMPATABLE = @"Protag Elite is only compatable with Iphone 4S and above";
    }
    return self;
}

-(void)AlertEvent:(WarningEvents)event{
    switch(event){
        case BLUETOOTH_OFF:
            if(![_WarningList containsObject:WARNING_BLUETOOTH_OFF])
                [_WarningList addObject:WARNING_BLUETOOTH_OFF];
            break;
        case BLUETOOTH_ON:
            [_WarningList removeObject:WARNING_BLUETOOTH_OFF];
            break;
        case BLUETOOTH_NOT_ALLOWED:
            if(![_WarningList containsObject:WARNING_BLUETOOTH_NOT_ALLOWED])
                [_WarningList addObject:WARNING_BLUETOOTH_NOT_ALLOWED];
            break;
        case BLUETOOTH_ALLOWED:
            [_WarningList removeObject:WARNING_BLUETOOTH_NOT_ALLOWED];
            break;
        case BLUETOOTH_NOT_COMPATABLE:
            if(![_WarningList containsObject:WARNING_BLUETOOTH_NOT_COMPATABLE])
                [_WarningList addObject:WARNING_BLUETOOTH_NOT_COMPATABLE];
            break;
        case GPS_OFF:
            if(![_WarningList containsObject:WARNING_GPS_OFF])
                [_WarningList addObject:WARNING_GPS_OFF];
            break;
        case GPS_ON:
            [_WarningList removeObject:WARNING_GPS_OFF];
            break;
        case GPS_NOT_ALLOWED:
            if(![_WarningList containsObject:WARNING_GPS_NOT_ALLOWED])
                [_WarningList addObject:WARNING_GPS_NOT_ALLOWED];
            break;
        case GPS_ALLOWED:
            [_WarningList removeObject:WARNING_GPS_NOT_ALLOWED];
            break;
        default:
            break;
    }

    for(int i=0;i<_ObserverList.count;i++)
        [((id<WarningObserver>)[_ObserverList objectAtIndex:i])AlertEvent:event];
}

-(void)registerObserver:(id<WarningObserver>)Observer{
    if(![_ObserverList containsObject:Observer])
       [_ObserverList addObject:Observer];
}
-(void)deregisterObserver:(id<WarningObserver>)Observer{
    [_ObserverList removeObject:Observer];
}

@end
