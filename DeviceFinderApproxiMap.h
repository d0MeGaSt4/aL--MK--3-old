#import <Foundation/Foundation.h>
#import "Protag_Device.h"

@interface DeviceFinderApproxiMap : NSObject{
    NSMutableArray *_PointArray;
    double _direction;
}

-(void)clearAllPoints;
-(void)addNewPointWithRSSI: (double)RSSI withDirection:(double)direction;
-(double)getDirectionToMoveTo;

@end
