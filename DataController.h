#import <Foundation/Foundation.h>

@interface DataController : NSObject{
    NSUserDefaults *_Prefs;
    bool bol_Not_First_Load;
}

@property (nonatomic) bool Settings_Vibration;
@property (nonatomic) bool Settings_AlarmOnSilent;

+(id)sharedInstance;//Singleton
-(void)save_Devices;
-(NSMutableArray*)load_Devices;
-(void)save_Settings;
-(void)load_Settings;

@end
