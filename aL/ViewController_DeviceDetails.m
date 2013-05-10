#import "ViewController_DeviceDetails.h"
#import "DataController.h"
#import "BluetoothController.h"
#import "Alarm.h"

static ViewController_Map *MapController;

@interface ViewController_DeviceDetails ()
@end

@implementation ViewController_DeviceDetails

@synthesize DetailsTable;
@synthesize Cell_DetailsName;
@synthesize Cell_DetailsDelete;
@synthesize Cell_DetailsRSSI;
@synthesize Cell_DetailsPhoneRSSI;
@synthesize btn_Distance;
@synthesize btn_Icons;
@synthesize btn_OnOff;
@synthesize Cell_DetailsBattery;
@synthesize Cell_DetailsDistance;
@synthesize Cell_DetailsIcons;
@synthesize Cell_DetailsLastDisconnected;
@synthesize Cell_DetailsLastLocation;
@synthesize Cell_DetailsOnOff;
@synthesize Cell_DetailsStatus;
@synthesize Cell_DetailsUUID;
@synthesize Cell_DetailsFindProtag;
@synthesize Cell_DetailsProximityProtag;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Register for refresh with MainController
    [[DeviceController sharedInstance]registerObserver:self];
    
    //Load the Nib for tableviewcells
    [[[NSBundle mainBundle] loadNibNamed:@"Cells_DeviceDetails" owner:self options:nil]objectAtIndex:0];
    
    MapController = [[ViewController_Map alloc]init];
    
    UIImageView *BackGroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.png"]];
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    
    tableView.opaque = NO;
    tableView.backgroundView = nil;
    
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSectionFooterHeight:10];
    [tableView setSectionHeaderHeight:10];
    [tableView setSeparatorColor:[UIColor darkGrayColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    BackGroundView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"Details";
    
    [self.view addSubview:BackGroundView];
    [self.view addSubview:tableView];
    
    DetailsTable = tableView;
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    [BackGroundView setFrame:self.view.frame];
    [tableView setFrame:self.view.frame];    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Register for refresh with MainController
    //[[MainController sharedInstance]registerForRefresh:self];
    [self RefreshDeviceTable];
 }

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //deregister for refresh with MainController
    //[[MainController sharedInstance]deregisterForRefresh:self];
}

-(void) viewDidUnload
{
    [super viewDidUnload];
    //deregister for refresh with MainController
    [[DeviceController sharedInstance]deregisterObserver:self];
}


- (void) RefreshDeviceTable{
    [DetailsTable reloadData];
}

- (void)UpdateDistance: (id)sender{
    NSLog(@"Update Distance");
    
    if(_device!=NULL && btn_Distance!=NULL)
        _device.index_Distance = [btn_Distance selectedSegmentIndex];
}


-(void)Show_NameInput{
    UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Change Name" message:@"Please Enter A New Name For The Device" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message setTag:1];
    [message show];
}

-(void)Show_DeleteConfirmation{
    UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Delete Device" message:@"Are you sure you want to delete the device?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [message setAlertViewStyle:UIAlertViewStyleDefault];
    [message setTag:2];
    [message show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch(section){
        case 0:
            return 3;//Device Name, Status, On Off
        case 1:
            return 4;//Battery Indicator, UUID, last Disconnected, Last known location
        case 2:
            return 3;//RSSI, Phone RSSI, Distance
        case 3:
            return 3;//Icon,Find this Protag, Proximity
        case 4:
            return 1;//Delete Device
        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _device = [[DeviceController sharedInstance]_DetailsDevice];
    
    UITableViewCell *cell;
    switch(indexPath.section){
        case 0:
            switch(indexPath.row){
                case 0:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsName"];
                    if(cell==NULL)
                        cell = Cell_DetailsName;
                    
                    UILabel *lbl_Name = (UILabel*)[cell.contentView viewWithTag:1];
                    [lbl_Name setText:_device.str_Name];
                    break;
                }
                case 1:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsStatus"];
                    if(cell==NULL)
                        cell = Cell_DetailsStatus;
                    
                    UILabel *lbl_Status = (UILabel*)[cell.contentView viewWithTag:1];
                    [lbl_Status setText:_device.str_Status];
                    break;
                }
                case 2:
                default:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsOnOff"];
                    if(cell==NULL)
                        cell = Cell_DetailsOnOff;
                    
                    btn_OnOff = (UISwitch*)[cell.contentView viewWithTag:1];
                    
                    if(_device.int_Status!=STATUS_CONNECTING)
                        [btn_OnOff setOn: (_device.int_Status==STATUS_CONNECTED)];
                    
                    [btn_OnOff addTarget:self action:@selector(toggleOnOff:) forControlEvents:UIControlEventValueChanged];
                    break;
            }
            break;
        case 1:
            switch(indexPath.row){
                case 0:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsBattery"];
                    if(cell==NULL)
                        cell = Cell_DetailsBattery;
                    
                    
                    UILabel *lbl_Battery = (UILabel*)[cell.contentView viewWithTag:1];
                    [lbl_Battery setText: [NSString stringWithFormat:@"%i%%",_device.int_Battery]];
                    break;
                }
                case 1:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsUUID"];
                    if(cell==NULL)
                        cell = Cell_DetailsUUID;
                    
                    
                    UILabel *lbl_UUID = (UILabel*)[cell.contentView viewWithTag:1];
                    [lbl_UUID setText: [_device str_UUID]];
                    break;
                }
                case 2:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsLastDisconnected"];
                    if(cell==NULL)
                        cell = Cell_DetailsLastDisconnected;
                    
                    
                    UILabel *lbl_DateLost = (UILabel*)[cell.contentView viewWithTag:1];
                    [lbl_DateLost setText:[_device str_DateLost]];
                    break;
                }
                case 3:
                default:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsLastLocation"];
                    if(cell == NULL)
                        cell = Cell_DetailsLastLocation;
                    break;
            }
            break;
        case 2:
            switch(indexPath.row){
                case 0:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsRSSI"];
                    if(cell==NULL)
                        cell = Cell_DetailsRSSI;
                    
                    UILabel *lbl_RSSI = (UILabel*)[cell.contentView viewWithTag:1];
                    [lbl_RSSI setText: [NSString stringWithFormat:@"%d",[_device get_RSSI]]];
                    break;
                }
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsPhoneRSSI"];
                    if(cell==NULL)
                        cell = Cell_DetailsPhoneRSSI;
                    
                    break;
                case 2:
                default:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsDistance"];
                    if(cell==NULL)
                        cell = Cell_DetailsDistance;
                    
                    btn_Distance = (UISegmentedControl*)[cell.contentView viewWithTag:1];
                    
                    if([_device index_Distance]<0 ||
                       [_device index_Distance]>=[btn_Distance numberOfSegments])
                    {
                        NSLog(@"Reset index_Distance");
                        _device.index_Distance = [btn_Distance numberOfSegments]-1;
                    }
                    [btn_Distance setSelectedSegmentIndex:[_device index_Distance]];
                    [btn_Distance sendActionsForControlEvents:UIControlEventValueChanged];
                    
                    [btn_Distance addTarget:self action:@selector(UpdateDistance:) forControlEvents:UIControlEventValueChanged];
                    break;
            }
            break;
        case 3:{
            switch(indexPath.row){
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsIcons"];
                    if(cell==NULL)
                        cell = Cell_DetailsIcons;
                    
                    btn_Icons = (UISegmentedControl*)[cell.contentView viewWithTag:1];
                    
                    //Update Icon
                    if([_device int_Icon]<0 ||
                       [_device int_Icon]>=[btn_Icons numberOfSegments])
                    {
                        NSLog(@"Reset int_Icon");
                        _device.int_Icon = 0;
                    }
                    [btn_Icons setSelectedSegmentIndex:[_device int_Icon]];
                    [btn_Icons sendActionsForControlEvents:UIControlEventValueChanged];
                    
                    [btn_Icons addTarget:self action:@selector(UpdateIcon:) forControlEvents:UIControlEventValueChanged];
                    break;
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsDeviceFinder"];
                    if(cell==NULL)
                        cell = Cell_DetailsFindProtag;
                    
                    break;
                case 2:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsDeviceProximity"];
                    if(cell==NULL)
                        cell = Cell_DetailsProximityProtag;
                    
                    break;
                    
            }
            break;
        }
        case 4:
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_DetailsDelete"];
            if(cell==NULL)
                cell = Cell_DetailsDelete;
            break;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(Cell_DetailsPhoneRSSI == [tableView cellForRowAtIndexPath:indexPath]){
        UILabel *lbl_RSSI = (UILabel*)[Cell_DetailsPhoneRSSI.contentView viewWithTag:1];
        [lbl_RSSI setText: [NSString stringWithFormat:@"%d",[_device get_PhoneRSSI]]];
        [Cell_DetailsPhoneRSSI setSelected:false];
    }else if(Cell_DetailsName == [tableView cellForRowAtIndexPath:indexPath]){
        NSLog(@"Change Name");
        [self Show_NameInput];
        [Cell_DetailsName setSelected:false];
    }else if(Cell_DetailsLastLocation == [tableView cellForRowAtIndexPath:indexPath]){
        NSLog(@"Show Last Location Map");
        [self.navigationController pushViewController:MapController animated:true];
    }else if(Cell_DetailsDelete == [tableView cellForRowAtIndexPath:indexPath]){
        NSLog(@"Cell Delete Device was pressed");
        [Cell_DetailsDelete setSelected:false];
        [self Show_DeleteConfirmation];
    }else if(Cell_DetailsFindProtag == [tableView cellForRowAtIndexPath:indexPath]){
        NSLog(@"Cell Find This Protag was pressed");
        [Cell_DetailsFindProtag setSelected:false];
        
        if(_device==NULL || [_device get_StatusCode]!=STATUS_CONNECTED)
        {
            UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Find This Protag" message:@"This function requires Protag to be connected" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [message setAlertViewStyle:UIAlertViewStyleDefault];
            [message show];
        }
        else{
            //[self PushToDeviceFinder];
            [[[DeviceController sharedInstance]_DetailsDevice]toggleSpeedUp];
        }
        }else if(Cell_DetailsProximityProtag == [tableView cellForRowAtIndexPath:indexPath]){
        NSLog(@"Cell Proximity Sensor was pressed");
        [Cell_DetailsProximityProtag setSelected:false];

        //[self PushToDeviceProximity];
        [self PushToRadar];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Setting background color of cell
    cell.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.4];
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==1)
    {
        //Change Name AlertView
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"OK"])
        {
            UITextField *text_newName = [alertView textFieldAtIndex:0];
            if([text_newName.text length] > 12)
            {
                text_newName.text = [text_newName.text substringToIndex:12];
            }
            if([text_newName.text length] == 0)
            {
                [self Show_NameInput];
            }
            else if(_device!=NULL)
                [_device setStr_Name:text_newName.text];
            [[DeviceController sharedInstance]RefreshDeviceTable];
            
            NSLog(@"Button OK was Pressed");
        }
        else {
            NSLog(@"Button Cancel was Pressed");
        }
    }
    else if(alertView.tag==2)
    {
        //Delete Confirmation AlertView
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Delete"])
        {
            NSLog(@"Button Delete was Pressed");
            [[DeviceController sharedInstance]remove_Device:_device];
            [[self navigationController]popViewControllerAnimated:true];//simulate the back button
        }
    }
}

-(void)toggleOnOff:(id)sender{
    if(_device!=NULL && btn_OnOff!=NULL)
    {
        if([btn_OnOff isOn])
            [_device Connect];
        else
            [_device Disconnect];
    }
}

- (void)UpdateIcon: (id)sender{
    NSLog(@"UpdateIcon");
    if(_device!=NULL && btn_Icons!=NULL)
    {
        [_device setInt_Icon:btn_Icons.selectedSegmentIndex];
    }
}

-(void)PushToDeviceFinder{
    if(DeviceFinderController==NULL)
        DeviceFinderController = [[ViewController_DeviceFinder alloc]init];
    
    [self.navigationController pushViewController: DeviceFinderController animated:true];
}

-(void)PushToDeviceProximity{
    if(DeviceProximityController==NULL)
        DeviceProximityController = [[ViewController_DeviceProximity alloc]init];
    
    [self.navigationController pushViewController: DeviceProximityController animated:true];
}

-(void)PushToRadar{
    if(RadarController==NULL)
        RadarController = [[ViewController_Radar alloc]init];
    
    [self.navigationController pushViewController: RadarController animated:true];
}

@end
