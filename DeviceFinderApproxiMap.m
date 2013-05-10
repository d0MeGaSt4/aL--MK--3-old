#import "DeviceFinderApproxiMap.h"
#import "DeviceFinderApproxiPoint.h"

//This class is used by DeviceFinder to map out the approximate location of the device user is looking for


@implementation DeviceFinderApproxiMap


-(id)init{
    self = [super init];
    if(self){
        _PointArray = [[NSMutableArray alloc]init];
        _direction = 0;
    }
    return self;
}

-(void)clearAllPoints{
    [_PointArray removeAllObjects];
}

-(void)addNewPointWithRSSI: (double)RSSI withDirection:(double)direction{
    
    DeviceFinderApproxiPoint* tempPoint = [[DeviceFinderApproxiPoint alloc]initWithRSSI: RSSI andDirection: direction];
    
    //tune sensitivity here
    int int_Sensitivity = 4;
    
    if(_PointArray.count==0 || [tempPoint getDifferenceInRSSI:_PointArray.lastObject]>=int_Sensitivity){
        [_PointArray addObject:tempPoint];
    }
    
    //Limit number of objects in PointArray
    if(_PointArray.count>10)
        [_PointArray removeObjectAtIndex:0];
    
    [self updateDirection];
}

-(void)updateDirection{
    if(_PointArray.count<2)
        return;
    DeviceFinderApproxiPoint* currentPoint=_PointArray.lastObject;
    DeviceFinderApproxiPoint* closestPoint=[_PointArray objectAtIndex:0];
    int closestPointIndex=0;
    
    //Find the closest point to the device
    for(int i=1;i<_PointArray.count;i++)
    {
        if(((DeviceFinderApproxiPoint*)[_PointArray objectAtIndex:i])._RSSI > closestPoint._RSSI){
            closestPoint = [_PointArray objectAtIndex:i];
            closestPointIndex=i;
        }
    }
    
    
    if([currentPoint isEqual:closestPoint]){
        _direction = currentPoint._direction;
    }else{
        int tempDirection = closestPoint._direction;
        for(int i=closestPointIndex;i<_PointArray.count;i++){
            tempDirection+=[closestPoint getAngleToMatchDirection:((DeviceFinderApproxiPoint*)[_PointArray objectAtIndex:i])];
        }
        _direction = (tempDirection+180)%360;
    }
}


-(double)getDirectionToMoveTo{
    return _direction;
}


@end
