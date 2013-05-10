#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "RingtoneController.h"

@class Protag_Device;

@protocol AlarmContainer <NSObject>
-(void)reduce_Second;
-(void)Set_Minutes:(int)minutes;
-(void)reduce_Seconds:(int)seconds;
@end


@interface Alarm : NSObject <UIAlertViewDelegate>{
    UITextView *TextView_LostDeviceNames;
    UIDatePicker *_TimePicker;
    NSTimer *_timer;
    NSTimeInterval interval_FromBackground;
    AVAudioPlayer* _avAudioPlayer;
}

@property (nonatomic) bool bol_isShown;
@property (nonatomic) UILocalNotification *_localNotification;
@property (nonatomic,retain)NSTimer *_silenceTimer;
@property (nonatomic) UIApplication *_app;

+(id)sharedInstance;
-(void)ShowAlert;
-(void)Vibrate;
-(void)Play_Music;
-(void)Play_Music:(Ringtone)tone;
-(void)Stop_MusicOnly; //Only used when choosing alarm, does not clear lost device
-(void)UpdateLostDeviceNames;
-(BOOL)isCharging;
-(BOOL)isInBackground;
-(void)ReduceSecondsForAllLostDevices;
-(void)ShowLocalNotification;
-(void)ScheduleLocalNotification:(NSInteger)minutes;
-(void)StopAlarm;
-(void)PauseTimer;
-(void)ResumeTimer;
-(void)ProtagAlertsPhone:(Protag_Device*)device;
 
@end
