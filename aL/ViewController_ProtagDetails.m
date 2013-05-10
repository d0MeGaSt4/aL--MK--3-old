//
//  ViewController_ProtagDetails.m
//  aL
//
//  Created by macbook on 5/7/13.
//
//

#import "ViewController_ProtagDetails.h"

@interface ViewController_ProtagDetails ()

@end

@implementation ViewController_ProtagDetails

@synthesize button_Belongings;
@synthesize button_Battery;
@synthesize button_UUID;
@synthesize button_DistanceSettings;
@synthesize button_RadarTracking;
@synthesize button_LastKnownLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self LoadButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)LoadButton
{
    button_Belongings = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button_Belongings addTarget:self
               action:@selector(aMethod:)
     forControlEvents:UIControlEventTouchDown];
    [button_Belongings setTitle:@"BELONGINGS" forState:UIControlStateNormal];
    button_Belongings.frame = CGRectMake(0.0, 0.0, 150.0, 140.0);
    [self.view addSubview:button_Belongings];
    button_Battery = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button_Battery addTarget:self
                          action:@selector(aMethod:)
                forControlEvents:UIControlEventTouchDown];
    [button_Battery setTitle:@"BATTERY" forState:UIControlStateNormal];
    button_Battery.frame = CGRectMake(150.0, 0.0, 150.0, 140.0);
    [self.view addSubview:button_Battery];
    
    button_UUID = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button_UUID addTarget:self
                          action:@selector(aMethod:)
                forControlEvents:UIControlEventTouchDown];
    [button_UUID setTitle:@"UUID" forState:UIControlStateNormal];
    button_UUID.frame = CGRectMake(0.0, 150.0, 150.0, 140.0);
    [self.view addSubview:button_UUID];
    button_DistanceSettings = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button_DistanceSettings addTarget:self
                          action:@selector(aMethod:)
                forControlEvents:UIControlEventTouchDown];
    [button_DistanceSettings setTitle:@"DISTANCE SETTINGS" forState:UIControlStateNormal];
    button_DistanceSettings.frame = CGRectMake(150.0, 150.0, 150.0, 140.0);
    [self.view addSubview:button_DistanceSettings];
    button_RadarTracking = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button_RadarTracking addTarget:self
                          action:@selector(aMethod:)
                forControlEvents:UIControlEventTouchDown];
    [button_RadarTracking setTitle:@"RADAR TRACKING" forState:UIControlStateNormal];
    button_RadarTracking.frame = CGRectMake(300.0, 0.0, 170.0, 140.0);
    [self.view addSubview:button_RadarTracking];
}

@end
