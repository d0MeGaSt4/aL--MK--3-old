//Buttons must in the following order: Snooze, Reconnect, Stop. Else you will have to modify the index according to new needs

#import "Alarm.h"
#import "Protag_Device.h"

#import "DeviceController.h"
#import "NotificationGrouper.h"
#import "DataController.h"
#import "ViewController_DeviceDetails.h"

#warning change this to UIView instead of UIAlertView since no difference

@implementation Alarm

@synthesize bol_isShown;
@synthesize _localNotification;


+(id)sharedInstance{
    static Alarm *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    if(self = [super init]){
        //Initialization
        bol_isShown=false;
        _timer=NULL;
        _localNotification = [[UILocalNotification alloc] init];
        _avAudioPlayer = NULL;
    }
    return self;
}


//Customize the the 3 buttons in alert as well as the frame size of the alert
- (void)willPresentAlertView:(UIAlertView *)alertView {
    if(alertView.tag==10)
    {
        //Set the frame size of Alertview
        alertView.frame = CGRectMake(0,100,320,290);
        //Set the frame/location of buttons on alertview
        UIButton *btn_Snooze=[(NSMutableArray*)[alertView valueForKey:@"_buttons"] objectAtIndex:0];
        btn_Snooze.frame=CGRectMake(9, 225, 99, 45);
        
        UIButton *btn_Reconnect=[(NSMutableArray*)[alertView valueForKey:@"_buttons"] objectAtIndex:1];
        btn_Reconnect.frame=CGRectMake(112, 225, 99, 45);
        
        UIButton *btn_Stop=[(NSMutableArray*)[alertView valueForKey:@"_buttons"] objectAtIndex:2];
        btn_Stop.frame=CGRectMake(215, 225, 99, 45);
    }
}


-(void)ShowAlert{
    NSLog(@"Show Alert");
    if(bol_isShown==false){
        bol_isShown=true;
        UIAlertView *_Alert = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Snooze",@"Reconnect",@"Stop", nil];
        _Alert.tag=10;
        NSArray *theView =  [[NSBundle mainBundle] loadNibNamed:@"Alarm" owner:self options:nil];
        UIView *_Alarm = [theView objectAtIndex:0];
        _TimePicker = (UIDatePicker*)[_Alarm viewWithTag:1];
        [_TimePicker setCountDownDuration:60];
        TextView_LostDeviceNames = (UITextView*)[_Alarm viewWithTag:2];
        [self UpdateLostDeviceNames];
        _Alarm.frame = CGRectMake(28 ,10, 265, 214);
        [_Alert addSubview:_Alarm];
        [_Alert show];
        [self Play_Music];
    }else
        [self UpdateLostDeviceNames];
    
    if([self isInBackground])
        [self ShowLocalNotification];
}

-(void)ProtagAlertsPhone:(Protag_Device*)device{
    NSString *str_Message = [NSString stringWithFormat:@"%@ is alerting the phone",device.str_Name];
    UIAlertView *_Alert = [[UIAlertView alloc]initWithTitle:nil message:str_Message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    _Alert.tag = 11;
    [self Play_Music];
    [_Alert show];
}

//Button actions
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    bol_isShown=false;
    if(alertView.tag == 10)
    {
        switch(buttonIndex){
            case 0:
            {
                NSLog(@"Pressed Snooze");
                
                for(int i=0;i<[[DeviceController sharedInstance]_LostDevices].count;i++)
                {
                    Protag_Device *device = (Protag_Device*)[[[DeviceController sharedInstance]_LostDevices]objectAtIndex:i];
                    [device Set_Minutes:[_TimePicker countDownDuration]/60];
                }
                [self ScheduleLocalNotification: [_TimePicker countDownDuration]/60];
                
                //if timer was not previously created, create it here
                if(_timer == NULL)
                    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(ReduceSecondsForAllLostDevices) userInfo:nil repeats:true];
                break;
            }
            case 1:
            {
                NSLog(@"Pressed Reconnect");
                NSMutableArray *tempArray = [[DeviceController sharedInstance]_LostDevices].mutableCopy;
                [[DeviceController sharedInstance]Clear_LostDevices];
                for(int i=0;i<tempArray.count;i++)
                {
                    Protag_Device *device = (Protag_Device*)[tempArray objectAtIndex:i];
                    [tempArray removeObjectAtIndex:i];
                    [device Connect];
                    i--;
                }
                break;
            }
            case 2:
            default: //default and case 2 both stop
                NSLog(@"Pressed Stop");
                [self StopAlarm];
                break;
        }
    }
    else {
        if(alertView.tag==11)
        {
            //Pressed ok
            
#warning stop music
        }
    }
}

-(void)StopAlarm{
    //stop music
    [self Stop_MusicOnly];
    
    //Clear lost device will auto set the new status
    [[DeviceController sharedInstance]Clear_LostDevices];
}

-(void)UpdateLostDeviceNames{
    if(TextView_LostDeviceNames!=NULL)
    {
        NSString *str_DeviceNames = @"";
        for(int i=0;i<[[DeviceController sharedInstance]_LostDevices].count;i++)
        {
            Protag_Device *device = (Protag_Device*)[[[DeviceController sharedInstance]_LostDevices]objectAtIndex:i];
            if([device SnoozeSeconds]==0)
            {
                if(i==0)
                    str_DeviceNames = device.str_Name;
                else
                    str_DeviceNames = [NSString stringWithFormat:@"%@, %@",str_DeviceNames,device.str_Name];
            }
        }
        [TextView_LostDeviceNames setText:str_DeviceNames];
    }
}

-(void)Play_Music{
    [self Play_Music:[[RingtoneController sharedInstance]get_ToneInt]];
}

-(void)Play_Music:(Ringtone)tone{
    NSLog(@"Playing Music");
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: [[RingtoneController sharedInstance]get_ToneGenericName:tone] ofType:[[RingtoneController sharedInstance]get_ToneType:tone]];
    NSURL* soundURL = [NSURL fileURLWithPath:soundPath];
    
    if(_avAudioPlayer!=NULL)
    {
        [_avAudioPlayer stop];
        _avAudioPlayer = NULL;
    }
    
    _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:NULL];
    
    //infinite loop
    [_avAudioPlayer setNumberOfLoops:-1];
    
    if([[DataController sharedInstance]Settings_AlarmOnSilent]){
        //Reroute music through speaker
        [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    else{
        //This will remove the rerouting to speaker
        [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    }
    
    // play sound
    [_avAudioPlayer play];
    
    [self Vibrate];
}

-(void)Stop_MusicOnly{
    [_avAudioPlayer stop];
}

-(void)Vibrate{
   if([[DataController sharedInstance]Settings_Vibration])
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(BOOL)isCharging{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging)
        return true;
    else
        return false;
}

-(BOOL)isInBackground{
    return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}

-(void)ShowLocalNotification{
    NSLog(@"Show Local Notification");
    //instant local notification
    [self ScheduleLocalNotification:0];
}


-(void)ScheduleLocalNotification:(NSInteger)minutes{

    if(minutes>=0)
    {
        NSLog(@"Schedule Local Notification");
        NotificationGrouper *_tempNotification = [[NotificationGrouper alloc]init];
        
        for(int i=0;i<[[DeviceController sharedInstance]_LostDevices].count;i++)
        {
            Protag_Device *device = (Protag_Device*)[[[DeviceController sharedInstance]_LostDevices]objectAtIndex:i];
            if([device SnoozeSeconds]==0)
                [_tempNotification add_Device:device];
        }
       /* for(int i=0;i<[[DeviceController sharedInstance]_currentDevices].count;i++)
        {
            Protag_Device *device = (Protag_Device*)[[[DeviceController sharedInstance]_currentDevices]objectAtIndex:i];
            if([device SnoozeSeconds] == 0)
                [_tempNotification add_Device:device];
        }*/
        [_tempNotification Schedule:minutes*60];
   }
}

-(void)ReduceSecondsForAllLostDevices{
    
    if([[DeviceController sharedInstance]_LostDevices].count==0)
    {
        //Reset alarm if there are no lost devices left
        if(_timer!=NULL)
        {
            [_timer invalidate];
            _timer = NULL;
        }
        return;
    }
    
    //If Snooze Timer reach 0, attempt reconnect
    for(int i=0;i<[[DeviceController sharedInstance]_LostDevices].count;i++)
    {
        Protag_Device *device = (Protag_Device*)[[[DeviceController sharedInstance]_LostDevices]objectAtIndex:i];
        [device reduce_Second];

        if([device SnoozeSeconds]==0 && [device int_Status] == STATUS_SNOOZE ){
            [device Connect];
        }
    }
}

-(void)PauseTimer{
    //NSTimer does not work in background so require to save the timing between background and active to update the timer values
    interval_FromBackground = [[NSDate date]timeIntervalSinceReferenceDate];
}

-(void)ResumeTimer{
    NSLog(@"Resuming Timer");
    interval_FromBackground = [[NSDate date]timeIntervalSinceReferenceDate] - interval_FromBackground;
    
    if(interval_FromBackground>0)
    {
        bool bol_ShowAlert = false;
        for(int i=0;i<[[DeviceController sharedInstance]_LostDevices].count;i++)
        {
            Protag_Device *device = (Protag_Device*)[[[DeviceController sharedInstance]_LostDevices]objectAtIndex:i];
            [device reduce_Seconds:(int)interval_FromBackground];
            if([device SnoozeSeconds]==0)
                bol_ShowAlert=true;
        }
        if(bol_ShowAlert==true)
            [self ShowAlert];
    }
    NSLog(@"Finish Resuming Timer");
}

@end
