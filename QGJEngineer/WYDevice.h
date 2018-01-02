//
//  WYDevice.h
//  WYDevice
//
//  Created by AlanWang on 14-9-10.
//  Copyright (c) 2014年 AlanWang. All rights reserved.
//
//  Email:alan.wang@smartwallit.com
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/*!
 *  @enum DeviceCommand
 *
 *  @discussion The command from device
 */
typedef NS_ENUM (NSInteger, DeviceCommand){
    COMMAND_FINDING_PHONE=0,// device is finding your phone
    COMMAND_FULL_BATTERY,//device is power full
    COMMAND_LOW_BATTERY,//device is low power
    COMMAND_NULL_BATTERY,//device is power off
    COMMAND_REMIND_TICK,//device tick every minute
    COMMAND_START_ALARM,//device is out of range,your phone should start alarm now
    COMMAND_STABLE,//The connection is stable
    COMMAND_STOP_ALARM,//device is nearby,your phone should stop alarm now
    COMMAND_STOP_FINDING_PHONE,//device stop find your phone
    COMMAND_WALLET_OPEN,//your wallet is open
    COMMAND_NEED_UPDATE_DISTURB// you need tell the device next disturb time
};



/*!
 *  @enum DeviceAlertMode
 *
 *  @discussion
 */
typedef NS_ENUM(NSInteger, DeviceAlertMode) {
    DeviceAlertModeRing=0,//device alert mode is ring
    DeviceAlertModeVibrate,//device alert mode is vibrate
    DeviceAlertModeBoth,//device alert mode is ring and vibrate
};

/*
 *  @enum DeviceAlertTimes
 *
 *  @discussion
 */
typedef NS_ENUM(NSInteger, DeviceAlertTimes) {
    DeviceAlertTimes_1=0,// the device will alert once when disconnect
    DeviceAlertTimes_3,//the device will alert 3 times when disconnect , default
    DeviceAlertTimes_5,//the device will alert 5 times when disconnect
};

/*!
 *  @enum DeviceVolumn
 *
 *  @discussion
 */
typedef NS_ENUM(NSInteger, DeviceVolumn) {
    DeviceVolumnNormal=0, //set the device alert volume normal, default
    DeviceVolumnLoud,//set the device alert volume loud
};


/*!
 *  @enum WalletPushInterval
 *
 *  @discussion
 */
typedef NS_ENUM(NSInteger,WalletPushInterval) {
    WalletPushInterval_10s=0,//set the wallet open notification interval 10 seconds
    WalletPushInterval_60s, //set the wallet open notification interval 60 seconds, default
    WalletPushInterval_120s,//set the wallet open notification interval 120 seconds
};
/*!
 *  @enum DeviceAlertDistance
 *
 *  @discussion
 */
typedef NS_ENUM(NSInteger,DeviceAlertDistance) {
    
    AlertDistanceNear=0,//set the alert distance:near
    AlertDistanceFar,//set the alert distance:far
};

typedef NS_ENUM(NSInteger,DeviceFindPhoneMode) {
    
    DeviceFindPhoneMode_Double=0,//double click the device's button to ring the phone
    DeviceFindPhoneMode_Triple,//triple click the device's button to ring the phone
};

/*!
 *  @enum WYDeviceState
 *
 *  @discussion Represents the current connection state of a WYDevice.
 *
 */
typedef NS_ENUM(NSInteger, WYDeviceState) {
	WYDeviceStateDisconnected = 0,
	WYDeviceStateConnecting,
	WYDeviceStateConnected,
};

typedef NS_ENUM(NSInteger, DeviceUpdate) {
    DeviceUpdateMax = 0,
    DeviceUpdateFast,
    DeviceUpdateSlow,
};


@protocol DeviceDelegate <NSObject>
@required

-(void)didConnect:(NSInteger) tag :(CBPeripheral *)peripheral;//

-(void)didDisconnect:(NSInteger)tag :(CBPeripheral *)peripheral;

@optional
-(void)didGetBattery:(NSInteger)tag :(NSInteger)battery :(CBPeripheral *)peripheral;

-(void)didGetDeviceName:(NSInteger)tag :(NSString *)name :(CBPeripheral *)peripheral;

-(void)didGetImageVerAndType:(NSInteger)tag :(NSInteger)ver :(char)type :(CBPeripheral *)peripheral;

-(void)didGetRssi:(NSInteger)tag :(NSInteger)rssi :(CBPeripheral *)peripheral;

-(void)didGetValue:(NSInteger)tag :(DeviceCommand)command :(CBPeripheral *)peripheral;

// 已弃用
-(void)didUpdateOADProgress:(NSInteger)tag :(NSInteger)progress :(CBPeripheral *)peripheral;

-(void)didGetKeyData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral;

-(void)didGetSensorData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral;

-(void)didGetEditionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral;

-(void)didGetVersionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral;

-(void)didGetBurglarCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral;

-(void)didGetMacStringCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral;
/*
 progress: 0~1
 secondLeft: the left time by second
 */
-(void)didGetOADProgress:(NSInteger)tag :(float)progress :(float)secondLeft;

@end

@protocol ScanDelegate <NSObject>
@required
-(void) didDiscoverPeripheral:(NSInteger)tag :(CBPeripheral *)peripheral scanData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
@optional
-(void) bluetoohPowerOn;
-(void) bluetoohPowerOff;

@end

@interface WYDevice : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (weak, nonatomic) id<DeviceDelegate>      deviceDelegate;
@property (weak, nonatomic ) id<ScanDelegate>       scanDelete;
@property ( retain, nonatomic )   CBCentralManager    *centralManager;
@property (nonatomic ,assign) int       tag;

@property (nonatomic ,retain) CBPeripheral        *peripheral;

@property (nonatomic)  BOOL upgrate;

@property (nonatomic)  int deviceStatus;

@property (nonatomic)    int lastMinitue;

@property (nonatomic) NSMutableArray *tempValuesArray;
@property (nonatomic) int historyLength;
@property (nonatomic) int packageNum;

@property (nonatomic) NSDate *historyStartDate;
@property (nonatomic) NSMutableArray *historyTempValuesArray;  //历史温度数组  贴片里面存的12小时的温度数据


/* Using this can make sure your app relaunch in background  even if it was killed because of  out of memory */
-(id)initWithRestoreIdentifier:(NSString *)identifier;

/*
  You can use this to retrieve the peripheral with the peripheral's uuidString you have saved before. if return is YES,retrieved succefully, else failed.
  This method is normally used  after your app launched, you can quickly reConnect the device you have connected before.
 
 e.g:
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
    WYDevice *device=[[WYDevice alloc]init];
 
    if([device retrievePeripheralWithUUID:@"the uuid you  have saved before"]){
       [device  connect];
    }

 }
  */

-(BOOL)retrievePeripheralWithUUID:(NSString *)uuidString;

/*
 You can use this method to get all CBPeripheral that being connected by Comtime APP.And then,connect the one you want use below code:
      WYDevice.peripheral=peripheral;
     [WYDevice.peripheral connect];
 
 @return		A list of <code>CBPeripheral</code> objects.
 */
-(NSArray*)retrieveConnectedDevice;

-(void)startScan;// start scan the peripheral nearby
-(void)startScan2;// start scan the peripheral nearby
-(void)stopScan;// stop scan

-(WYDeviceState)getConnectState;// get the connection of device, see {@link WYDeviceState}
-(void)remove; // cancel and unbind the connection
-(void)connect; //start connect the device
-(void)disConnect;//cancel the connection

-(void)ring; // start let the device ring
-(void)stopRing;// stop ring the device
-(void)readDeviceName;// to read the devicename, see didGetDeviceName in DeviceDelegate
-(void)readBattery;// to read the device battery, see  didGetBattery in DeviceDelegate
-(void)readRssi;//While connected, retrieves the current RSSI of the link, see {@link didGetRssi}  in DeviceDelegate
-(void)readDiviceInformation;
-(void)readDiviceMac;
-(void)readDeviceVersion;
-(void)readDiviceVersion;

-(void)syncStableStatus;//While conneted, communicate with device to sync the state of connection, if stable ,will get COMMAND_STABLE, see {@link DeviceCommand}
-(void)setAlertDistance:(DeviceAlertDistance)distance;//set the device alert distance, near or far
-(void)setDeviceAlertTimes:(DeviceAlertTimes )times;//set the device alert times, see {@link DeviceAlertTimes}
-(void)setDeviceAlertMode:(DeviceAlertMode)mode;//set the device alert mode, see {@link DeviceAlertMode}
-(void)setDeviceVolumn:(DeviceVolumn )volumn;//set the device  volumn, see enum DeviceVolumn
-(void)setWalletPushInterval:(WalletPushInterval)interval;//see enum WalletPushInterval
-(void)startAntilost;// open the anti-lost function that: the device will alert when it is disconnected
-(void)stopAntilost;//close the anti-lost function
-(void)startInterimNotDisturb;// start not disturb for the next 3 hours
-(void)stopInterimNotDisturb;// stop the function
-(void)startNotDisturb;// don't disturb when disconnected
-(void)stopNotDisturb;// stop the function
-(void)startWalletPushFunction;//open the function that notify your phone when wallet is open
-(void)stopWalletPushFunction;//close the function that notify your phone when wallet is open

-(void)sendKeyValue:(NSData *)data;

-(void)sendUpgrateValue:(NSData *)data;

-(void)sendAccelerationValue;

-(void)setDeviceUpdate:(DeviceUpdate)update;

-(void)setDeviceFindPhoneMode:(DeviceFindPhoneMode)mode;// set the mode that device how to find the phone, see {@link DeviceFindPhoneMode}

-(BOOL)hasKeyFunction;
-(BOOL)hasOADFunction;

-(void)startOADMode;

// return total time  by second
-(float)sendOADData:(NSData*)data;

-(void)stopOAD;

-(void)setFastOAD:(BOOL)fast;// default is YES
-(void)setOADPackageNum:(NSInteger)num;

-(void)setOADPackageInterval:(float)interval;

-(void)setdEBUG:(BOOL)debug;

-(void)sendHexstring:(NSString *)string;

-(BOOL)isConnected;

@end
