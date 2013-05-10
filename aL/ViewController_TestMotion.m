//Class just for testing the motion

#import "ViewController_TestMotion.h"

@interface ViewController_TestMotion ()

@end

@implementation ViewController_TestMotion

- (void)viewDidLoad
{
    [super viewDidLoad];
    axis_y = 0;
    
    UIImageView *BackGroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];
    
    [self.view setAutoresizesSubviews:true];

    
    self.title = @"Test Motion";
    
    BackGroundView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    [self.view addSubview:BackGroundView];

    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    [BackGroundView setFrame:self.view.frame];
    
    
    //Altitude meter
    lbl_pitch = [[UILabel alloc]init];
    lbl_yaw = [[UILabel alloc]init];
    lbl_roll = [[UILabel alloc]init];
    lbl_direction = [[UILabel alloc]init];
    lbl_Tilt = [[UILabel alloc]init];
    lbl_Speed = [[UILabel alloc]init];
    lbl_distance = [[UILabel alloc]init];
    lbl_ToGoDirection = [[UILabel alloc]init];
    lbl_ToGoDistance = [[UILabel alloc]init];
    
    //Accelerometer
    lbl_x = [[UILabel alloc]init];
    lbl_y = [[UILabel alloc]init];
    lbl_z = [[UILabel alloc]init];
    
    [self setupLabel:lbl_pitch];
    [self setupLabel:lbl_yaw];
    [self setupLabel:lbl_roll];
    [self setupLabel:lbl_direction];
    [self setupLabel:lbl_Tilt];
    [self setupLabel:lbl_Speed];
    [self setupLabel:lbl_distance];
    
    [self setupLabel:lbl_x];
    [self setupLabel:lbl_y];
    [self setupLabel:lbl_z];
    
    [self setupLabel:lbl_ToGoDirection];
    [self setupLabel:lbl_ToGoDistance];
    
        
    _Finder = [[DeviceFinder alloc]init];
}

-(void)setupLabel:(UILabel*)label{
    [label setFrame:CGRectMake(0,axis_y,310,30)];
    
    axis_y+=30;
    
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:label];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_Finder set_Observer:self];
    [_Finder StartSearching];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_Finder StopSearching];
    [_Finder set_Observer:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//delegate methods
- (void) Update:(double)currentDirection andDirectionToMove:(double)direction andDistance: (double) distance{
    [lbl_pitch setText:[NSString stringWithFormat:@"pitch: %f",_Finder._MotionManager.deviceMotion.attitude.pitch]];
    [lbl_yaw setText:[NSString stringWithFormat:@"yaw: %f",_Finder._MotionManager.deviceMotion.attitude.yaw]];
    [lbl_roll setText:[NSString stringWithFormat:@"roll: %f",_Finder._MotionManager.deviceMotion.attitude.roll]];
    
    [lbl_direction setText: [NSString stringWithFormat:@"direction: %f",_Finder._CurrentDirection]];
    [lbl_Speed setText: [NSString stringWithFormat:@"speed: %f",_Finder._CurrentSpeed]];
    
    [lbl_distance setText: [NSString stringWithFormat:@"distance: %f",_Finder._CurrentDistance]];
    [lbl_Tilt setText:[NSString stringWithFormat:@"tilt: %f",_Finder._CurrentTilt]];
    
    [lbl_x setText:[NSString stringWithFormat:@"x: %f",_Finder._MotionManager.deviceMotion.userAcceleration.x]];
    [lbl_y setText:[NSString stringWithFormat:@"y: %f",_Finder._MotionManager.deviceMotion.userAcceleration.y]];
    [lbl_z setText:[NSString stringWithFormat:@"z: %f",_Finder._MotionManager.deviceMotion.userAcceleration.z]];
    
    [lbl_ToGoDirection setText:[NSString stringWithFormat:@"to go Direction: %f",direction]];
    [lbl_ToGoDistance setText:[NSString stringWithFormat:@"to go Distance: %f",distance]];
}

- (void) AbortFinder{
    //DO nothing
}

@end
