#import "ViewController_TableDevices.h"
#import "Protag_Device.h"
#import "DeviceController.h"
#import "ViewController_DeviceDetails.h"
#import "ViewController_DevicesWithSideMenu.h"


@implementation ViewController_TableDevices

@synthesize currentDeviceTable;
@synthesize Cell_DeviceName;
@synthesize Cell_DeviceStatus;
@synthesize Cell_Snooze;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Register for refresh with MainController
    [[DeviceController sharedInstance]registerObserver:self];
    
    UIImageView *BackGroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.png"]];
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleGrouped];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    
    [BackGroundView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    tableView.opaque = NO;
    tableView.backgroundView = nil;
    
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSectionFooterHeight:10];
    [tableView setSectionHeaderHeight:10];
    [tableView setSeparatorColor:[UIColor darkGrayColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setShowsVerticalScrollIndicator:true];
    [tableView setRowHeight:37];
    
    currentDeviceTable = tableView;
    
    BackGroundView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    [self.view addSubview:BackGroundView];
    [self.view addSubview:tableView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Register for refresh with MainController
    [self RefreshDeviceTable];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //deregister for refresh with MainController
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    //deregister for refresh with MainController
    [[DeviceController sharedInstance]deregisterObserver:self]; 
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[[DeviceController sharedInstance]_currentDevices]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //If device is in snooze mode, show dismiss snooze
    //else just show 2
    Protag_Device *device = [[[DeviceController sharedInstance]_currentDevices]objectAtIndex:section];
    if(device.int_Status==STATUS_SNOOZE)
        return 3;
    else
        return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Protag_Device *device = (Protag_Device*)[[[DeviceController sharedInstance]_currentDevices]objectAtIndex:indexPath.section];
    UITableViewCell *cell;
    
    if(indexPath.row==0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Device1"];
        if(cell==NULL)
        {
            [self reloadNib];
            cell = Cell_DeviceName;
            Cell_DeviceName=NULL;
        }
        
        UILabel *lbl_Name = (UILabel*)[cell viewWithTag:1];
        lbl_Name.text = [device str_Name];
        
        if(device.int_Status != STATUS_CONNECTING)
        {
            UISwitch *btn_OnOff = (UISwitch*)[cell viewWithTag:2];
            [btn_OnOff setOn: (device.int_Status == STATUS_CONNECTED)];

            [btn_OnOff addTarget:self action:@selector(toggleOnOff:) forControlEvents:UIControlEventValueChanged];
        }
        return cell;
    }
    else if(indexPath.row==1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Device2"];
        if(cell==NULL)
        {
            [self reloadNib];
            cell = Cell_DeviceStatus;
            Cell_DeviceStatus=NULL;
        }
        UILabel *lbl_Status = (UILabel*)[cell viewWithTag:1];
        [lbl_Status setText:device.str_Status];
        return cell;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Device3"];
        if(cell==NULL)
        {
            [self reloadNib];
            cell = Cell_Snooze;
            Cell_Snooze=NULL;
        }
        return cell;
    }
}

-(void)reloadNib{
    //Load the Nib for tableviewcells
    [[[NSBundle mainBundle] loadNibNamed:@"Cells_CurrentDevices" owner:self options:nil]objectAtIndex:0];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1)
    {
        [[DeviceController sharedInstance]set_DetailsDevice:[[[DeviceController sharedInstance]_currentDevices]objectAtIndex: indexPath.section]];
        UITableViewCell *temp_cell = [tableView cellForRowAtIndexPath:indexPath];
        [temp_cell setSelected:false];
        
        //Access Parent view to push to details view (so that we only have 1 details viewcontroller
        UIViewController *tempController = [self parentViewController];
        while(![tempController isKindOfClass:[ViewController_DevicesWithSideMenu class]])tempController = [tempController parentViewController];
        
        [((ViewController_DevicesWithSideMenu*)tempController) PushToDetails];
        
    }
    else if(indexPath.row==2)
    {
        //dismiss snooze
        UITableViewCell *temp_cell = [tableView cellForRowAtIndexPath:indexPath];
        [temp_cell setSelected:false];
        
        Protag_Device *device = [[[DeviceController sharedInstance]_currentDevices]objectAtIndex: indexPath.section];
        [device DismissSnooze];
        //Attempt reconnect again
        [device Connect];

        [self RefreshDeviceTable];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Setting background color of cell
    cell.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.4];
}

- (void) RefreshDeviceTable{
    [currentDeviceTable reloadData];
}

-(void)toggleOnOff:(id)sender{
    if([sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *btn_OnOff = (UISwitch*)sender;
        
        //Find out which row it came from (need to superview 2 times)
        NSIndexPath *indexPath=[currentDeviceTable indexPathForCell:(UITableViewCell*)btn_OnOff.superview.superview];
        
        Protag_Device *_device = (Protag_Device*)[[[DeviceController sharedInstance]_currentDevices]objectAtIndex:indexPath.section];
        
        if(_device!=NULL && btn_OnOff!=NULL)
        {
            if([btn_OnOff isOn])
                [_device Connect];
            else {
                [_device Disconnect];
            }
        }
    }
}


@end
