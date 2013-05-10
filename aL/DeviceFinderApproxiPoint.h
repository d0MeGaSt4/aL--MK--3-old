#import <Foundation/Foundation.h>

@interface DeviceFinderApproxiPoint : NSObject

@property (nonatomic) double _RSSI;
@property (nonatomic) double _direction;

-(id)initWithRSSI: (double)RSSI andDirection: (double)direction;
-(int)getDifferenceInRSSI:(DeviceFinderApproxiPoint*)point;
-(int)getAngleToMatchDirection:(DeviceFinderApproxiPoint*)point;

@end
