#import <Foundation/Foundation.h>
#include <CoreMotion/CoreMotion.h>
#import "Protag_Device.h"
#import "DeviceFinderApproxiMap.h"

@protocol FinderObserver <NSObject>
- (void) Update:(double)currentDirection andDirectionToMove:(double)direction andDistance: (double) distance;
- (void) AbortFinder;
@end

@interface DeviceFinder : NSObject{
    NSTimer *_UpdateTimer;
    double _UpdateFrequency;
    double _PrevSpeed;
    double _PrevDistance;
    double _PrevAccele,_CurrentAccele;
    DeviceFinderApproxiMap *_ApproxiMap;
}

@property (nonatomic) CMMotionManager *_MotionManager;
@property (nonatomic,retain) Protag_Device *_device;
@property (nonatomic,assign) id<FinderObserver> _Observer;
@property (nonatomic) double _CurrentDirection;
@property (nonatomic) double _CurrentSpeed;
@property (nonatomic) double _CurrentTilt;
@property (nonatomic) double _CurrentDistance;

-(void)StartSearching;
-(void)StopSearching;

@end