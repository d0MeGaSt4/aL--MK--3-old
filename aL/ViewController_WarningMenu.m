#import "ViewController_WarningMenu.h"
#import "WarningController.h"

@interface ViewController_WarningMenu ()

@end


@implementation ViewController_WarningMenu


@synthesize Cell_Fine;
@synthesize Cell_Warning;
@synthesize _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc]init];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    
    [self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    [self.view addSubview:_tableView];
    
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSectionFooterHeight:10];
    [_tableView setSectionHeaderHeight:10];
    [_tableView setSeparatorColor:[UIColor darkGrayColor]];

    _tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    [_tableView setFrame:self.view.frame];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
    [[WarningController sharedInstance]registerObserver:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[WarningController sharedInstance]deregisterObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([[[WarningController sharedInstance]_WarningList]count]>0)
        return [[[WarningController sharedInstance]_WarningList]count];
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    UITableViewCell *cell;
    if([[[WarningController sharedInstance]_WarningList]count]>0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Warning"];
        if(cell==NULL){
            [self reloadNib];
            cell = Cell_Warning;
            Cell_Warning=NULL;
        }
        
        UILabel *lbl_Warning = (UILabel*)[cell viewWithTag:1];
        [lbl_Warning setText:[[[WarningController sharedInstance]_WarningList]objectAtIndex:indexPath.row]];
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Fine"];
        if(cell==NULL){
            [self reloadNib];
            cell = Cell_Fine;
            Cell_Fine = NULL;
        }
    }
    
    return cell;
}

-(void)reloadNib{
    //Load the Nib for tableviewcells
    [[[NSBundle mainBundle] loadNibNamed:@"Cells_WarningMenu" owner:self options:nil]objectAtIndex:0];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//WarningController delegate
-(void)AlertEvent:(WarningEvents)event{
    [_tableView reloadData];
}

@end
