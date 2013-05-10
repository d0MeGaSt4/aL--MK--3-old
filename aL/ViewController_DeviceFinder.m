

#import "ViewController_DeviceFinder.h"
#import "DeviceController.h"

@interface ViewController_DeviceFinder ()

@end

@implementation ViewController_DeviceFinder

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Load the Nib for tableviewcells
    UIView *mainView = [[[NSBundle mainBundle] loadNibNamed:@"View_DeviceFinder" owner:self options:nil]objectAtIndex:0];
    [self setView: mainView];
    
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"Device Finder";
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    
    img_Arrow = (UIImageView*)[mainView viewWithTag:1];
    lbl_Distance = (UILabel*)[mainView viewWithTag:2];
    
    _DeviceFinder = [[DeviceFinder alloc]init];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_DeviceFinder set_Observer:self];
    [_DeviceFinder set_device:[[DeviceController sharedInstance]_DetailsDevice]];
    [_DeviceFinder StartSearching];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_DeviceFinder StopSearching];
    [_DeviceFinder set_device:NULL];
    [_DeviceFinder set_Observer:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) Update:(double)currentDirection andDirectionToMove:(double)direction andDistance: (double) distance{
    //Relative position of the direction
    int tempInt = currentDirection-direction;
    
    [self rotateImage:img_Arrow duration:1 curve:UIViewAnimationCurveEaseIn degrees:tempInt];
    NSString *tempstr = [NSString stringWithFormat:@"Distance Left: %f meters",distance];
    NSLog(@"distance: %f",distance);
    [lbl_Distance setText:tempstr];
}

-(void) AbortFinder{
    [[self navigationController]popViewControllerAnimated:true];
}

//http://mobiledevelopertips.com/user-interface/rotate-an-image-with-animation.html
- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
              curve:(int)curve degrees:(CGFloat)degrees
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The transform matrix
    CGAffineTransform transform =
    CGAffineTransformMakeRotation([self Convert_DegreeToRadian:degrees]);
    image.transform = transform;
    
    // Commit the changes
    [UIView commitAnimations];
}

-(double)Convert_DegreeToRadian:(double) angle{
    return angle / 180.0 * M_PI;
}

@end
