#import "DataController.h"
#import "DeviceController.h"
#import "Protag_Device.h"
#import "RingtoneController.h"


//Constants
NSString * const KEY_DEVICES = @"KEY_DEVICES";
NSString * const KEY_VIBRATION = @"KEY_VIBRATION";
NSString * const KEY_ALARMONSILENT = @"KEY_ALARMONSILENT";
NSString * const KEY_NOT_FIRST_LOAD = @"KEY_NOT_FIRST_LOAD";
NSString * const KEY_TONE = @"KEY_TONE";

@implementation DataController

@synthesize Settings_AlarmOnSilent;
@synthesize Settings_Vibration;

//Singleton
+(id)sharedInstance{
    static DataController *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    if(self = [super init]){
        _Prefs = [NSUserDefaults standardUserDefaults];
        
        //bol_Not_First_Load is used to have a initial setting for the other settings because all settings will return false if there are no saved settings        bol_Not_First_Load = false;
        [self load_Settings];
        
        //Default values for Settings
        if(bol_Not_First_Load==false){
            Settings_Vibration = true;
            Settings_AlarmOnSilent = false;
        }
    }
    return self;
}

-(void)save_Devices{
    //Must save the custom class in a special way
    NSMutableArray* _save = [[NSMutableArray alloc]init];
    NSMutableArray* _devices = [[DeviceController sharedInstance] _currentDevices];
    
    for(int i=0;i<_devices.count;i++){
        [_save addObject:[NSKeyedArchiver archivedDataWithRootObject:[_devices objectAtIndex:i]]];
        NSLog(@"Saved %@",[[_devices objectAtIndex:i]str_Name]);
    }
    
    [_Prefs setObject: _save forKey:KEY_DEVICES];
    [_Prefs synchronize];
}

-(NSMutableArray*)load_Devices{
    //When retrieving saved values it returns NSArray which does not allow us to edit, thus we need to convert it to NSMUtableArray
    NSArray* _oldSave = [_Prefs objectForKey:KEY_DEVICES];
    NSMutableArray* _newDeviceList = [[NSMutableArray alloc]init];
    
    
    //if no previous save, return a empty NSMutableArray
    if(_oldSave==NULL)
        return [[NSMutableArray alloc]init];
    
    for(int i=0;i<_oldSave.count;i++)
    {
        //Add object to list
        Protag_Device *temp = (Protag_Device*)[NSKeyedUnarchiver unarchiveObjectWithData:[_oldSave objectAtIndex:i]];
        [_newDeviceList addObject:temp];
        
        NSLog(@"Loaded %@",temp.str_Name);
    }
    return _newDeviceList;
}

-(void)save_Settings{
    [_Prefs setBool:Settings_Vibration forKey:KEY_VIBRATION];
    [_Prefs setBool:Settings_AlarmOnSilent forKey:KEY_ALARMONSILENT];
    [_Prefs setInteger:[[RingtoneController sharedInstance]get_ToneInt] forKey:KEY_TONE];
    [_Prefs setBool:true forKey:KEY_NOT_FIRST_LOAD];
}

-(void)load_Settings{
    bol_Not_First_Load=[_Prefs boolForKey:KEY_NOT_FIRST_LOAD];
    Settings_Vibration=[_Prefs boolForKey:KEY_VIBRATION];
    Settings_AlarmOnSilent=[_Prefs boolForKey:KEY_ALARMONSILENT];
    [[RingtoneController sharedInstance]set_Tone:[_Prefs integerForKey:KEY_TONE]];
}

@end
