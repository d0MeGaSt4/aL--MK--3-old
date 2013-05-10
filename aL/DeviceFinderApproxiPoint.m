#import "DeviceFinderApproxiPoint.h"

//A class used in DeviceFinderApproxiMap to model points on map

@implementation DeviceFinderApproxiPoint

@synthesize _RSSI;
@synthesize _direction;

-(id)initWithRSSI:(double)RSSI andDirection:(double)direction{
    self = [super init];
    if(self){
        _RSSI = RSSI;
        _direction = direction;
    }
    return self;
}

-(int)getDifferenceInRSSI:(DeviceFinderApproxiPoint*)point{
    if(_RSSI>point._RSSI)
        return _RSSI - point._RSSI;
    else
        return point._RSSI - _RSSI;
}

-(int)getAngleToMatchDirection:(DeviceFinderApproxiPoint*)point{
    //anti clockwise (because the system gives me like that)
    int tempInt = point._direction-_direction;
    if(tempInt<=180)
        return tempInt;
    else
        return tempInt-360;
}

@end
