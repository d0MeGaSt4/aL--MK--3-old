#import "ViewController_DevicesWithSideMenu.h"

//This view controller houses the ViewController_WarningMenu and ViewConroller_PageScroll


@interface ViewController_DevicesWithSideMenu ()

@end

@implementation ViewController_DevicesWithSideMenu

@synthesize btn_Warning;

-(id)init{    
    CenterController = [[ViewController_PageScroll alloc]init];
    
    WarningMenu = [[ViewController_WarningMenu alloc]init];
    
    self = [super initWithCenterViewController:CenterController leftViewController:WarningMenu];
    
    if (self) {    
        UIImage *animatedImage = [UIImage animatedImageWithImages: [[NSArray alloc]initWithObjects:[UIImage imageNamed:@"ex1"],[UIImage imageNamed:@"ex2"], nil] duration:1];
        
        DetailsController = [[ViewController_DeviceDetails alloc]init];
        //ProtagDetailsController = [[ViewController_ProtagDetails alloc]init];
        
        btn_Warning = [[UIBarButtonItem alloc]initWithImage:animatedImage style:UIBarButtonItemStyleBordered target:self action:@selector(ToggleSideMenu)];
        [self setDelegate:self];
        
         self.title = @"Protag";
        
        [self.view setAutoresizesSubviews:true];
        
        }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[WarningController sharedInstance]registerObserver:self];
    [self UpdateVisibilityOfWarningMenuBtn];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[WarningController sharedInstance]deregisterObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark delegate methods

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated{
    [CenterController PagesScrollView].scrollEnabled=true;
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated{
    [CenterController PagesScrollView].scrollEnabled=false;
}

#pragma mark end of delegate methods

-(void)ToggleSideMenu{
    [self toggleLeftViewAnimated:true];
}

-(void)PushToDetails{
    NSLog(@"PushToDetails");
    
    [self.navigationController pushViewController:DetailsController animated:true];
    //[self.navigationController pushViewController:ProtagDetailsController animated:true];
}

-(void)UpdateVisibilityOfWarningMenuBtn{
    if([[WarningController sharedInstance]_WarningList].count>0)
        //show the warning button
        ((UINavigationItem*)[self.navigationController.navigationBar.items objectAtIndex:0]).leftBarButtonItem=btn_Warning;
    else
        //hide warning button
        ((UINavigationItem*)[self.navigationController.navigationBar.items objectAtIndex:0]).leftBarButtonItem=NULL;
}

-(void)AlertEvent:(WarningEvents)event{
    [self UpdateVisibilityOfWarningMenuBtn];
}

@end
