#import "NotificationGrouper.h"
#import "RingtoneController.h"

//Used to group the local notification for devices together
//Because iOS cannot call the application to pop up
//This notification refers to iOS notification
                                                               
@implementation NotificationGrouper

-(id)init{
    self = [super init];
    if(self)
    {
        //initalization
        _DeviceList = [[NSMutableArray alloc]init];
        _LocalNotification = [[UILocalNotification alloc] init];
        _LocalNotification.fireDate = NULL;
        bol_Unscheduling=false;
    }
    return self;
}

-(void)add_Device:(Protag_Device*)device{
    if(![_DeviceList containsObject:device])
    {
        [_DeviceList addObject:device];
        device._Notification=self;
    }
}

-(void)Schedule :(int)interval{ //iOS interval (seconds)
    //It is in interval and not minutes because settings might cause local notification to turn on and off at unpredictable timings
    
#warning should set interval notification so that it alerts multiple times instead of just 1 notification
    //[[UIApplication sharedApplication]cancelAllLocalNotifications];
    
    _LocalNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    _LocalNotification.timeZone = [NSTimeZone defaultTimeZone];

    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    //device names
    NSString *str_DeviceNames = @"";
    
    for(int i=0;i<_DeviceList.count;i++)
    {
        Protag_Device *device = (Protag_Device*)[_DeviceList objectAtIndex:i];
        if(i==0)
            str_DeviceNames = device.str_Name;
        else
            str_DeviceNames = [NSString stringWithFormat:@"%@, %@",str_DeviceNames,device.str_Name];
    }
    
	// Notification details
    _LocalNotification.alertBody = [NSString stringWithFormat:@"The following devices are lost: %@",str_DeviceNames];
    
	// Set the action button
    _LocalNotification.alertAction = @"View";
    
    _LocalNotification.soundName = [[RingtoneController sharedInstance]get_ToneFilename];
    _LocalNotification.applicationIconBadgeNumber+=1;
    
	// Specify custom data for the notification
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
    _LocalNotification.userInfo = infoDict;
    
	// Schedule the notification
    
    NSLog(@"scheduling notification grouper, device %@ and interval",str_DeviceNames);
    //NSLog(@"date %@",_LocalNotification.fireDate);
    [[UIApplication sharedApplication] scheduleLocalNotification:_LocalNotification];

}

-(void)Unschedule{
    NSLog(@"%@",_LocalNotification.fireDate);
    if(bol_Unscheduling==false){
        NSLog(@"Unscheduling Notification Grouper");
        
        bol_Unscheduling=true;

        NSLog(@"CancelingLocalNotifcation");
       
        //Unschedule the localnotification
        if(_LocalNotification!=NULL && _LocalNotification.fireDate!=NULL)
        {
            NSLog(@"%@",_LocalNotification.fireDate);
            NSComparisonResult result = [_LocalNotification.fireDate compare:[NSDate date]];
            if(result == NSOrderedAscending)
            {
                [[UIApplication sharedApplication] cancelLocalNotification:_LocalNotification];
            }
        }
        
        //Remove all pointers to this notification
        while(_DeviceList.count>0)
        {
            Protag_Device *device = (Protag_Device*)[_DeviceList objectAtIndex:0];
            [device set_Notification:NULL];//Do not use UnscheduleNotification else will cause loop
            [_DeviceList removeObjectAtIndex:0];
        }
        
        NSLog(@"Notification Grouper finished Unscheduling");
    }
}

@end
