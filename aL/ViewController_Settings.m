#import "ViewController_Settings.h"
#import "Alarm.h"
#import "ViewController_TestMotion.h"
#import "DataController.h"

@interface ViewController_Settings ()

@end

@implementation ViewController_Settings

@synthesize Cell_Settings;
@synthesize Cell_OnOff;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    UIImageView *BackGroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];

    UITableView *tableView = [[UITableView alloc]init];
    
    [self.view setAutoresizesSubviews:true];
    
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSectionFooterHeight:10];
    [tableView setSectionHeaderHeight:10];
    [tableView setSeparatorColor:[UIColor darkGrayColor]];
   
    [tableView setShowsHorizontalScrollIndicator:false];
    [tableView setShowsVerticalScrollIndicator:true];
    
    self.title = @"Settings";
    
    BackGroundView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    [self.view addSubview:BackGroundView];
    [self.view addSubview:tableView];
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    [BackGroundView setFrame:self.view.frame];
    [tableView setFrame:self.view.frame];
    
     _RingtoneController = [[ViewController_Ringtone alloc]init];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.row<=1){
        //For On Off Settings
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_OnOff"];
        
        if(cell==NULL){
            [self reloadNib];
            cell=Cell_OnOff;
            Cell_OnOff=NULL;
        }
        
        if(cell!=NULL)
        {
            UILabel *lbl_OnOff = (UILabel*)[cell viewWithTag:1];
            UISwitch *_Switch = (UISwitch*)[cell viewWithTag:2];
            
            switch(indexPath.row){
                case 0:
                    [lbl_OnOff setText:@"Vibration"];
                    [_Switch setOn:[[DataController sharedInstance]Settings_Vibration]];
                    [_Switch addTarget:self action:@selector(ToggleVibration:) forControlEvents:UIControlEventValueChanged];
                    break;
                case 1:
                    [lbl_OnOff setText:@"Alarm On Silent"];
                    [_Switch setOn:[[DataController sharedInstance]Settings_AlarmOnSilent]];
                    [_Switch addTarget:self action:@selector(ToggleAlarmOnSilent:) forControlEvents:UIControlEventValueChanged];
                    break;
            }
        }
    }
    else{
        //For Other Settings
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Settings"];
        
        if(cell==NULL){
            [self reloadNib];
            cell=Cell_Settings;
            Cell_Settings=NULL;
        }
        
        if(cell!= NULL)
        {
            UILabel *lbl_Setting = (UILabel*)[cell viewWithTag:1];
            // Configure the cell...
            
            switch(indexPath.row){
                case 2:
                    [lbl_Setting setText:@"Select Ringtone"];
                    break;
                case 3:
                    [lbl_Setting setText:@"About"];
                    break;
                case 4:
                    [lbl_Setting setText:@"Test Alarm"];
                    break;
                case 5:
                    [lbl_Setting setText:@"Test Motion"];
                    break;
                default:
                    break;
            }
        }
    }
    
    return cell;
}

-(void)reloadNib{
    //Load the Nib for tableviewcells
    [[[NSBundle mainBundle] loadNibNamed:@"Cells_Settings" owner:self options:nil]objectAtIndex:0];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Select ringtone
    if(indexPath.row==2)
    {
        [self.navigationController pushViewController:_RingtoneController animated:true];
    }

    //For the about button
    else if(indexPath.row == 3)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"\n\n\n\n\n" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"innovaLogo.png"]];
        [imageView setFrame:CGRectMake(20, 20, 70, 50)];
        [alertView addSubview:imageView];
        
        UILabel *companyNamelabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 20, 150, 50)];
        [companyNamelabel setTextColor:[UIColor whiteColor]];
        [companyNamelabel setFont:[UIFont boldSystemFontOfSize:16]];
        [companyNamelabel setText:@"Innova Technology"];
        [companyNamelabel setBackgroundColor:[UIColor clearColor]];
        [alertView addSubview:companyNamelabel];
        
        UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 75, 260, 40)];
        [contentTextView setEditable:FALSE];
        [contentTextView setTextColor:[UIColor whiteColor]];
        [contentTextView setFont:[UIFont systemFontOfSize:14]];
        contentTextView.contentMode = UIViewAutoresizingFlexibleWidth;
        [contentTextView setBackgroundColor:[UIColor clearColor]];
        [contentTextView setClipsToBounds:TRUE];
#warning to change this next time. Not done by MK, by Suarap I think
        [contentTextView setTextAlignment:UITextAlignmentCenter];
        contentTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        [contentTextView setText:@"http://www.innovatechnology.com.sg/\n Version:1.0"];
        [alertView addSubview:contentTextView];
        
        [alertView show];
    }
    
    else if(indexPath.row==4)
    {
        [[Alarm sharedInstance] ShowAlert];
    }
    
    else if(indexPath.row==5)
    {
        [self.navigationController pushViewController:[[ViewController_TestMotion alloc]init] animated:true];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}



-(void)ToggleVibration:(id)sender{
    if([sender isKindOfClass: [UISwitch class]]){
        NSLog(@"Toggle Vibration");
        UISwitch *_Switch = (UISwitch*)sender;
        [[DataController sharedInstance]setSettings_Vibration:[_Switch isOn]];
    }
}

-(void)ToggleAlarmOnSilent:(id)sender{
    if([sender isKindOfClass: [UISwitch class]]){
        NSLog(@"Toggle Alarm On Silent");
        UISwitch *_Switch = (UISwitch*)sender;
        [[DataController sharedInstance]setSettings_AlarmOnSilent:[_Switch isOn]];
    }
}

@end
