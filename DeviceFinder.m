#import "DeviceFinder.h"

@implementation DeviceFinder


@synthesize _Observer;
@synthesize _device;
@synthesize _MotionManager;
@synthesize _CurrentDirection;
@synthesize _CurrentSpeed;
@synthesize _CurrentTilt;
@synthesize _CurrentDistance;

-(id)init{
    self = [super init];
    if(self){
        _MotionManager = [[CMMotionManager alloc]init];
        _ApproxiMap = [[DeviceFinderApproxiMap alloc]init];
        _UpdateTimer = NULL;
        _UpdateFrequency = 0.25;
    }
    return self;
}


-(void)ScheduleUpdate:(double)interval{

    [_MotionManager setDeviceMotionUpdateInterval:interval];
    if(_UpdateTimer!=NULL)
    {
        [_UpdateTimer invalidate];
        _UpdateTimer=NULL;
    }
    
    _UpdateTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(UpdateMotion) userInfo:nil repeats:true];
}

-(void)UpdateMotion{
    if(_device!=NULL && [_device get_StatusCode]!=STATUS_CONNECTED){
       [_Observer AbortFinder];
        [self StopSearching];
        return;
    }
    
    //yaw in degrees only gives -180 to 180, once it passes 180, it goes to -180
    //Radian to Degrees
    _CurrentDirection = _MotionManager.deviceMotion.attitude.yaw * 180/M_PI;
    
    //This is to make it 0 to 360
    if(_CurrentDirection<0)
        _CurrentDirection = 360+_CurrentDirection;
    
    
    if(_Observer!=NULL){
        if(_device!=NULL)
            [_Observer Update: _CurrentDirection andDirectionToMove:[_ApproxiMap getDirectionToMoveTo] andDistance:[_device RSSItoDistance]];
        else
            [_Observer Update: _CurrentDirection andDirectionToMove:[_ApproxiMap getDirectionToMoveTo] andDistance:0];

    }
}

//ignore this
-(void)DummyFunction2{
    /*
    //yaw in degrees only gives -180 to 180, once it passes 180, it goes to -180
    //Radian to Degrees
    _CurrentDirection = _MotionManager.deviceMotion.attitude.yaw * 180/M_PI;
    
    //This is to make it 0 to 360
    if(_CurrentDirection<0)
        _CurrentDirection = 360+_CurrentDirection;
    
    
    //_CurrentTilt only gives -90 to 90, once it passes 90, it will reduce to 0
    _CurrentTilt = _MotionManager.deviceMotion.attitude.pitch * 180/M_PI;
    
    
    // Subtract the low-pass value from the current value to get a simplified high-pass filter
    double kFilteringFactor = 0.05;
    
    _PrevAccele = _CurrentAccele;
    _CurrentAccele = _MotionManager.deviceMotion.userAcceleration.y - ( (_MotionManager.deviceMotion.userAcceleration.y * kFilteringFactor) + (_CurrentAccele  * (1.0 - kFilteringFactor)) );
    
    _PrevSpeed = _CurrentSpeed;
    _PrevDistance = _CurrentDistance;
    
    _CurrentSpeed = ((_CurrentAccele + _PrevAccele)/2 * 9.81 * _UpdateFrequency + _PrevSpeed)/2;
    
    //will go wrong if the person tilts more than 45 degrees
    
    double avgSpeed = (_CurrentSpeed + _PrevSpeed)/2;
    
    _CurrentDistance = 0;
    if(avgSpeed>0.003 && !(_MotionManager.deviceMotion.rotationRate.z< -1.5 || _MotionManager.deviceMotion.rotationRate.z>1.5)){
        //_CurrentDistance = (avgSpeed * _UpdateFrequency + _PrevDistance);
        _CurrentDistance = avgSpeed * _UpdateFrequency;//Not total distance
    }
    
    if(_device!=NULL)
        [_ApproxiMap addNewPoint_Distance:_CurrentDistance withDirection:_CurrentDirection withRadius:[_device RSSItoDistance]];
    
    if(_Observer!=NULL){
        if(_device!=NULL)
            [_Observer Update:[_ApproxiMap getDirectionToMoveTo] and:[_device RSSItoDistance]];
        else
            [_Observer Update:[_ApproxiMap getDirectionToMoveTo] and:0];
    }
    */
}

//ignore this
-(void)DummyFunction{
    
    //Used to store some unused codes (which didn't work but took a hell lot of time, hurts me to delete them);
    
    //Grab the forward motion speed by removing the gravity caused by tilt on the accelerometer y and z.
    
    //Approximate gravity after removing gravity acting on x-plane
    //Since roll goes from -180 to 180, all gravity will act on x-plane when it is +-90
    //Gravity here is used in G (Gravity units 9.81), so it is just 1
    
    /*double approxi_Gravity = 1;
     
     _CurrentRoll = fabs(_CurrentRoll);
     if(_CurrentRoll<=90)
     approxi_Gravity = 1-approxi_Gravity*(_CurrentRoll/90);
     else
     approxi_Gravity = 1-approxi_Gravity*((180-_CurrentRoll)/90);
     
     NSLog(@"Gravity: %f",approxi_Gravity);
     
     double _ApproxY = _MotionManager.deviceMotion.userAcceleration.y;
     double _ApproxZ = _MotionManager.deviceMotion.userAcceleration.z;
     
     NSLog(@"check: %f",fabs(_ApproxY)+fabs(_ApproxZ)+fabs(_MotionManager.deviceMotion.userAcceleration.x));
     
     NSLog(@"before removing gravity Y: %f, Z: %f",_ApproxY,_ApproxZ);
     
     //Remove gravity from the other axis
     _ApproxY = _ApproxY-((-1*approxi_Gravity)/sin(_CurrentTilt));
     _ApproxZ = _ApproxZ+(approxi_Gravity/cos(_CurrentTilt));
     
     NSLog(@"after removing gravity Y: %f, Z: %f",_ApproxY,_ApproxZ);
     
     //Find the correct acceleration in the forward direction
     
     _CurrentSpeed = _ApproxY*cos(_CurrentTilt)+((-1*_ApproxZ)*cos(_CurrentTilt));
     //Covert to m/s^2
     _CurrentSpeed = _CurrentSpeed*9.81;
     
     */
    
}


-(void)StartSearching{
    [_MotionManager startDeviceMotionUpdates];
    [self ScheduleUpdate:_UpdateFrequency];
    [_ApproxiMap clearAllPoints];
}

-(void)StopSearching{
    [_MotionManager stopDeviceMotionUpdates];
    _device = NULL;
    if(_UpdateTimer!=NULL)
    {
        [_UpdateTimer invalidate];
        _UpdateTimer=NULL;
    }
}

@end