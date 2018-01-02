//
//  WYDevice.m
//  WYDevice
//
//  Created by AlanWang on 14-9-10.
//  Copyright (c) 2014年 AlanWang. All rights reserved.
//

#import "WYDevice.h"
//下发设备数据


#define RSSI_REPORT_DISABLE         7   /* 设备关闭上报RSSI */
#define RSSI_REPORT_ENABLE          8   /* 设备开启上报RSSI */

#define IPHONE_STATUS_STABLE        9   /* 手机稳定时下发给设备告知设备 */

#define DEVICE_VOLUME_NORMAL        11  /* 设备报警音量 */
#define DEVICE_VOLUME_LOUD          13

#define PERIPHERAL_ALERT_TYPE_RING    21  /* 21、22、23 声音、振动、声音+振动（设备报警类型）*/
#define PERIPHERAL_ALERT_TYPE_VIBRATE 22
#define PERIPHERAL_ALERT_TYPE_BOTH    23

#define ANDROID_RANGE_NEAR          30
#define ANDROID_RANGE_MIDDLE        31
#define ANDROID_RANGE_FAR           32

#define IOS_RANGE_NEAR              33
#define IOS_RANGE_MIDDLE            34
#define IOS_RANGE_FAR               35

#define EXIST_REMIND_0              40  /* 40、42、44 46 无、10分钟、20分钟、30分钟（存在提醒）*/
#define EXIST_REMIND_10             42
#define EXIST_REMIND_20             44
#define EXIST_REMIND_30             46

#define WALLET_IS_OPEN              51  /* 打开钱包推送功能 */
#define WALLET_IS_CLOSE             50  /* 关闭钱包推送功能 */

#define WALLET_TYPE_MAN             60  /* 男包 */
#define WALLET_TYPE_WOMAN           61  /* 女包 */

#define DEVICE_NSTIMER_CLOSE        80  /* 设备关闭计时器 */

#define WALLET_OPEN_REMIND_ON       72  /* 设备断线后打开钱包滴一声提醒 */
#define WALLET_OPEN_REMIND_OFF      73

#define DEVICE_HALF_HOUR_REMIND_ON  74  /* 设备断线后每半小时滴一声提醒 */
#define DEVICE_HALF_HOUR_REMIND_OFF 75

#define WALLET_OPEN_INTERVAL_10     85  /* 钱包推送时间 10秒 */
#define WALLET_OPEN_INTERVAL_30     86  /* 钱包推送时间 30秒 */
#define WALLET_OPEN_INTERVAL_60     87  /* 钱包推送时间 60秒 */


//#define DISTANCE_NEAR               90  /* 近距离模式 */
//#define DISTANCE_FAR                91  /* 远距离模式 */

#define PREVENT_LOST_ENABLE         93  /* 开启防丢功能 */
#define PREVENT_LOST_DISABLE        94  /* 关闭防丢功能 */


#define SLTMD_ALL_ALERT_ON          95  /* 临时勿扰开启 */
#define SLTMD_ALL_ALERT_OFF         96  /* 临时勿扰关闭 */

#define SLTMD_SCHEDULE_ALERT_ON     97  /* 时间表勿扰开启 */
#define SLTMD_SCHEDULE_ALERT_OFF    98  /* 时间表勿扰关闭 */

#define OAD_CLOSE                   100 /* 关闭OAD */
#define OAD_OPEN                    101 /* 开启OAD */

#define DIVCE_AUTO_POWEROFF_ON      102 /* 设备自动关机开起 */
#define DIVCE_AUTO_POWEROFF_OFF     103 /* 设备自动关机关闭 */

#define FIND_MODE_DOUBLE            106 /* 设备双击寻找手机 */
#define FIND_MODE_THIPLE            107 /* 设备三击寻找手机 */

#define DEVICE_ALERT_TIMES_1        111 /* 设备报警次数 1、3、5*/
#define DEVICE_ALERT_TIMES_3        113
#define DEVICE_ALERT_TIMES_5        115
//



//2014-08-30
#define DEVICE_UPDATE_MAX           122 //全速 （最快）
#define DEVICE_UPDATE_FAST          121 //快速 （中等）
#define DEVICE_UPDATE_SLOW          120 //慢速 （慢速）

//增加安卓系统蓝牙防丢误报多问题，比如：小米3手机、索尼Z，增加下面功能命令。
// Anti Lost Compatible,solve the problem of false alarm
#define SETTING_ANDROID_ALC_ON      104
#define SETTING_ANDROID_ALC_OFF     105

#define HI_UINT16(a) (((a) >> 8) & 0xff)
#define LO_UINT16(a) ((a) & 0xff)

#ifndef __OAD_H__
#define __OAD_H__

#define uint16 uint16_t
#define uint8 uint8_t
#define HAL_FLASH_WORD_SIZE 4

#ifdef __cplusplus
extern "C"
{
#endif
    
    /*********************************************************************
     * INCLUDES
     */
#define ATT_UUID_SIZE 128
#define KEY_BLENGTH    16
    
    /*********************************************************************
     * CONSTANTS
     */
    
#if !defined OAD_IMG_A_PAGE
#define OAD_IMG_A_PAGE        1
#define OAD_IMG_A_AREA        62
#endif
    
#if !defined OAD_IMG_B_PAGE
    // Image-A/B can be very differently sized areas when implementing IBM vice OAD boot loader.
#if defined FEATURE_OAD_IBM
#define OAD_IMG_B_PAGE        8
#else
#define OAD_IMG_B_PAGE        63
#endif
#define OAD_IMG_B_AREA       (124 - OAD_IMG_A_AREA)
#endif
    
#if defined HAL_IMAGE_B
#define OAD_IMG_D_PAGE        OAD_IMG_A_PAGE
#define OAD_IMG_D_AREA        OAD_IMG_A_AREA
#define OAD_IMG_R_PAGE        OAD_IMG_B_PAGE
#define OAD_IMG_R_AREA        OAD_IMG_B_AREA
#else   //#elif defined HAL_IMAGE_A or a non-IBM-enabled OAD Image-A w/ constants in Bank 1 vice 5.
#define OAD_IMG_D_PAGE        OAD_IMG_B_PAGE
#define OAD_IMG_D_AREA        OAD_IMG_B_AREA
#define OAD_IMG_R_PAGE        OAD_IMG_A_PAGE
#define OAD_IMG_R_AREA        OAD_IMG_A_AREA
#endif
    
#define OAD_IMG_CRC_OSET      0x0000
#if defined FEATURE_OAD_SECURE
#define OAD_IMG_HDR_OSET      0x0000
#else  // crc0 is calculated and placed by the IAR linker at 0x0, so img_hdr_t is 2 bytes offset.
#define OAD_IMG_HDR_OSET      0x0002
#endif
    
#define OAD_CHAR_CNT          2
    
#define OAD_CHAR_IMG_NOTIFY   0
#define OAD_CHAR_IMG_BLOCK    1
    
#define OAD_LOCAL_CHAR        0 // Local OAD characteristics
#define OAD_DISC_CHAR         1 // Discovered OAD characteristics
    
    // OAD Parameter IDs
#define OAD_LOCAL_CHAR_NOTIFY 1 // Handle for local Image Notify characteristic. Read only. size uint16.
#define OAD_LOCAL_CHAR_BLOCK  2 // Handle for local Image Block characteristic. Read only. size uint16.
#define OAD_DISC_CHAR_NOTIFY  3 // Handle for discovered Image Notify characteristic. Read/Write. size uint16.
#define OAD_DISC_CHAR_BLOCK   4 // Handle for discovered Image Block characteristic. Read/Write. size uint16.
    
    // Image Identification size
#define OAD_IMG_ID_SIZE       4
    
    // Image header size (version + length + image id size)
#define OAD_IMG_HDR_SIZE      ( 2 + 2 + OAD_IMG_ID_SIZE )
    
    // The Image is transporte in 16-byte blocks in order to avoid using blob operations.
#define OAD_BLOCK_SIZE        16
#define OAD_BLOCKS_PER_PAGE  (HAL_FLASH_PAGE_SIZE / OAD_BLOCK_SIZE)
#define OAD_BLOCK_MAX        (OAD_BLOCKS_PER_PAGE * OAD_IMG_D_AREA)
    
    /*********************************************************************
     * GLOBAL VARIABLES
     */
    
    // OAD Service UUID
    //extern CONST uint8 oadServUUID[ATT_UUID_SIZE];
    
    // OAD Image Notify, OAD Image Block Request, OAD Image Block Response UUID's:
    //extern CONST uint8 oadCharUUID[OAD_CHAR_CNT][ATT_UUID_SIZE];
    
    /*********************************************************************
     * TYPEDEFS
     */
    
    // The Image Header will not be encrypted, but it will be included in a Signature.
    typedef struct {
#if defined FEATURE_OAD_SECURE
        // Secure OAD uses the Signature for image validation instead of calculating a CRC, but the use
        // of CRC==CRC-Shadow for quick boot-up determination of a validated image is still used.
        uint16 crc0;       // CRC must not be 0x0000 or 0xFFFF.
#endif
        uint16 crc1;       // CRC-shadow must be 0xFFFF.
        // User-defined Image Version Number - default logic uses simple a '<' comparison to start an OAD.
        uint16 ver;
        uint16 len;        // Image length in 4-byte blocks (i.e. HAL_FLASH_WORD_SIZE blocks).
        uint8  uid[4];     // User-defined Image Identification bytes.
        uint8  res[4];     // Reserved space for future use.
    } img_hdr_t;
#if defined FEATURE_OAD_SECURE
    static_assert((sizeof(img_hdr_t) == 16), "Bad SBL_ADDR_AES_HDR definition.");
    static_assert(((sizeof(img_hdr_t) % KEY_BLENGTH) == 0),
                  "img_hdr_t is not an even multiple of KEY_BLENGTH");
#endif
    
    // The AES Header must be encrypted and the Signature must include the Image Header.
    typedef struct {
        uint8 signature[KEY_BLENGTH];  // The AES-128 CBC-MAC signature.
        uint8 nonce12[12];             // The 12-byte Nonce for calculating the signature.
        uint8 spare[4];
    } aes_hdr_t;
    
    
#ifdef __cplusplus
}
#endif

#endif


@implementation WYDevice{

    CBService           *services;//设备下发值 服务
    CBCharacteristic    *batteryAChar;
    CBCharacteristic    *nameAChar;
    CBCharacteristic    *keyAChar;//密钥字符串属性
    CBCharacteristic    *AccelerationChar;//读取Mac地址
    CBCharacteristic    *SensorChar;//通知上报传感器数据
    CBCharacteristic    *editionChar;//固件版本号
    CBCharacteristic    *versionChar;//硬件版本号
    CBCharacteristic    *macChar;
    CBCharacteristic    *upgradeChar;//升级通道
    
    CBCharacteristic    *oadImageNotifyChar;
    
    
    BOOL hasOADFunction;
    BOOL hasKeyFunction;
    
     int                                               nBlocks;
     int                                               nBytes;
     int                                               iBlocks;
     int                                               iBytes;
     NSData                         *imageFile;

    NSMutableArray *instructionsArray;
    
    BOOL runningOAD;
 
    
    NSInteger SEND_PACKAGE_NUMBER;
    float SEND_PACKAGE_INTERVAL;
    BOOL debug;
}
@synthesize deviceDelegate;
@synthesize scanDelete;
@synthesize centralManager;

-(id)init{
    self = [super init];
    centralManager   = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  
    SEND_PACKAGE_NUMBER=4;
    SEND_PACKAGE_INTERVAL=0.03;
    
    instructionsArray = [[NSMutableArray alloc]init];
    _tempValuesArray=[[NSMutableArray alloc]init];
    _historyTempValuesArray=[[NSMutableArray alloc]init];
    for (int i=0; i<480; i++) {
        [_tempValuesArray addObject:[NSNumber numberWithInt:0]];
    }

    
    return self;
}
-(id)initWithRestoreIdentifier:(NSString *)identifier{
    self = [super init];
    if(self){
        centralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil options: @{ CBCentralManagerOptionRestoreIdentifierKey:identifier}];
       
        SEND_PACKAGE_NUMBER=4;
        SEND_PACKAGE_INTERVAL=0.03;
    }
    return  self;
}

//这个方法的作用,就是根据uuid取到外设.
-(BOOL)retrievePeripheralWithUUID:(NSString *)uuidString{
    if(uuidString!=nil && ![uuidString isEqualToString:@""]){
        NSUUID *nsuuid=[[NSUUID alloc]initWithUUIDString:uuidString];
        NSArray *deices=  [centralManager retrievePeripheralsWithIdentifiers:[[NSArray alloc]initWithObjects:nsuuid, nil]];
        if(deices.count>0){
            _peripheral=deices[0];
            return YES;
        }
    }      
    return NO;

}

-(NSArray *)retrieveConnectedDevice{
    
    
   NSArray*array= [centralManager retrieveConnectedPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"1805"]]];
    
    NSMutableArray *devices=[[NSMutableArray alloc]init];
    NSString *string1=@"SmartWallit";
        NSString *string2=@"SmartKee";
        NSString *string3=@"SafeWallet";
    
    for (CBPeripheral *per in array) {
        
        if( [per.name rangeOfString:string1].location!=NSNotFound ||[per.name rangeOfString:string2].location!=NSNotFound||[per.name rangeOfString:string3].location!=NSNotFound ){
            [devices addObject:per];
        }
    }
    
    return devices;
}

-(void)startScan{
    //  [centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"1805"]]  options:nil];
    [centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

-(void)startScan2{
    //  [centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"1805"]]  options:nil];
    [centralManager scanForPeripheralsWithServices:nil options:nil];
}

-(void)stopScan{
    [centralManager stopScan];
}
-(void)remove{
    if(_peripheral){
        [centralManager cancelPeripheralConnection:_peripheral];
    }
    _peripheral=nil;
    _deviceStatus=0;
    [self reset];
}
-(void)reset{
    services=nil;
    batteryAChar=nil;
    nameAChar=nil;
    keyAChar=nil;
    AccelerationChar = nil;
    SensorChar = nil;
    editionChar = nil;
    versionChar = nil;
    macChar = nil;
    upgradeChar = nil;
    
}
-(void)ring{
    if(services){
        for (CBCharacteristic *aChar in services.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A08"]])
            {
                uint8_t val = 1;
                NSData  *valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                [_peripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
                break;
            }
        }
    }
}
-(void)stopRing{
    if(services ){
        for (CBCharacteristic *aChar in services.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A08"]])
            {
                uint8_t val = 0;
                NSData  *valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                [_peripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
                break;
            }
        }
    }
}

-(void)setDeviceAlertMode:(DeviceAlertMode)mode{
    if(mode==DeviceAlertModeRing){
        [self sendSetting:PERIPHERAL_ALERT_TYPE_RING];
    }else if (mode==DeviceAlertModeVibrate){
        [self sendSetting:PERIPHERAL_ALERT_TYPE_VIBRATE];
    }else if (mode==DeviceAlertModeBoth){
        [self sendSetting:PERIPHERAL_ALERT_TYPE_BOTH];
    }
}
-(void)setDeviceAlertTimes:(DeviceAlertTimes)times{
    if(times==DeviceAlertTimes_1){
        [self sendSetting:DEVICE_ALERT_TIMES_1];
    }else if (times==DeviceAlertTimes_3){
        [self sendSetting:DEVICE_ALERT_TIMES_3];
    }else if (times==DeviceAlertTimes_5){
        [self sendSetting:DEVICE_ALERT_TIMES_5];
    }
}
-(void)setDeviceVolumn:(DeviceVolumn)volumn{
    if(volumn==DeviceVolumnNormal){
        [self sendSetting:DEVICE_VOLUME_NORMAL];
    }else if (volumn==DeviceVolumnLoud){
        [self sendSetting:DEVICE_VOLUME_LOUD];
    }
}
-(void)setWalletPushInterval:(WalletPushInterval)interval{
    if(interval==WalletPushInterval_10s){
        [self sendSetting:WALLET_OPEN_INTERVAL_10];
    }else if(interval==WalletPushInterval_60s){
        [self sendSetting:WALLET_OPEN_INTERVAL_30];
    }else if(interval==WalletPushInterval_120s){
        [self sendSetting:WALLET_OPEN_INTERVAL_60];
    }
}
-(void)setAlertDistance:(DeviceAlertDistance)distance{
    if(distance==AlertDistanceNear){
        [self sendSetting:IOS_RANGE_NEAR];
    }else if (distance==AlertDistanceFar){
        [self sendSetting:IOS_RANGE_FAR];
    }
}

-(void)startAntilost{
    [self sendSetting:PREVENT_LOST_ENABLE];
}
-(void)stopAntilost{
    [self sendSetting:PREVENT_LOST_DISABLE];
}
-(void)startInterimNotDisturb{
    [self sendSetting:SLTMD_ALL_ALERT_ON];
}
-(void)stopInterimNotDisturb{
    [self sendSetting:SLTMD_ALL_ALERT_OFF];
}
-(void)startNotDisturb{
    [self sendSetting:SLTMD_SCHEDULE_ALERT_ON];
}
-(void)stopNotDisturb{
    [self sendSetting:SLTMD_SCHEDULE_ALERT_OFF];
}
-(void)startWalletPushFunction{
    [self sendSetting:WALLET_IS_OPEN];
}
-(void)stopWalletPushFunction{
    [self sendSetting:WALLET_IS_CLOSE];
}
-(void)sendSetting:(NSInteger)value{
    if(services ){
        
        if(value== IOS_RANGE_FAR || value==IOS_RANGE_MIDDLE || value==IOS_RANGE_NEAR){
            
            for (CBCharacteristic *aChar in services.characteristics)
            {
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A09"]])
                {
                   // NSLog(@"send 2A09 :%d ",value);
                    uint8_t val = value;
                    NSData  *valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                    [_peripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
                    break;
                }
            }
        }else{
            for (CBCharacteristic *aChar in services.characteristics)
            {
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A08"]])
                {
                  //  NSLog(@"send 2A08 :%d ",value);
                    
                    uint8_t val = value;
                    NSData  *valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                    [_peripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
                    break;
                }
            }
        }
    }
}
-(void)connect{
    if(_peripheral){
        // NSLog(@"do connect  %@",_uuid);
        [centralManager connectPeripheral:_peripheral options:nil];
    }
}

-(void)disConnect{
    if(_peripheral)
        [centralManager cancelPeripheralConnection:_peripheral];
}

-(void)readBattery{
    if(batteryAChar==nil){
        NSLog(@"batteryAChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;
        
    }
    [_peripheral readValueForCharacteristic: batteryAChar];
}

-(void)readDiviceInformation{
    
    if(editionChar==nil){
        NSLog(@"editionChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;
        
    }

        [_peripheral readValueForCharacteristic: editionChar];
}

-(void)readDiviceVersion{
    
    if(versionChar==nil){
        NSLog(@"versionChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;
        
    }
    
    [_peripheral readValueForCharacteristic:versionChar];
}

-(void)readDiviceMac{
    
    if(macChar==nil){
        NSLog(@"macChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;
        
    }
    
    [_peripheral readValueForCharacteristic: macChar];
}

-(void)readDeviceName{
    if(nameAChar==nil){
         NSLog(@"nameAChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;

    }
    [_peripheral readValueForCharacteristic: nameAChar];
}
-(void)readDeviceVersion{
    if(!hasOADFunction){
        NSLog(@"don't have OADFunction");
        return;
    }
    unsigned char data = 0x00;
    [_peripheral writeValue:[NSData dataWithBytes:&data length:1] forCharacteristic:oadImageNotifyChar type:CBCharacteristicWriteWithResponse];
    unsigned char data1 = 0x01;
    [_peripheral writeValue:[NSData dataWithBytes:&data1 length:1] forCharacteristic:oadImageNotifyChar type:CBCharacteristicWriteWithResponse];
    
}

-(void)readRssi{
    if(_peripheral.state==CBPeripheralStateConnected){
        [_peripheral readRSSI];
    }
}
-(void)syncStableStatus{
    if(_peripheral.state==CBPeripheralStateConnected){
        [self sendSetting:IPHONE_STATUS_STABLE];
    }
}
-(void)setDeviceFindPhoneMode:(DeviceFindPhoneMode)mode{
    if(mode==DeviceFindPhoneMode_Double){
        [self sendSetting:FIND_MODE_DOUBLE];
    }else if (mode==DeviceFindPhoneMode_Triple){
        [self sendSetting:FIND_MODE_THIPLE];
    }
}

-(void)setDeviceUpdate:(DeviceUpdate)update{
    switch (update) {
        case DeviceUpdateMax:
            [self sendSetting:DEVICE_UPDATE_MAX];
            break;
        case DeviceUpdateSlow:
            [self sendSetting:DEVICE_UPDATE_SLOW];
            break;
        case DeviceUpdateFast:
            [self sendSetting:DEVICE_UPDATE_FAST];
            break;
        default:
            break;
    }
}


-(BOOL)hasKeyFunction{
    return hasKeyFunction;
}
-(BOOL)hasOADFunction{
    return hasOADFunction;
}
-(WYDeviceState)getConnectState{
    if(_peripheral){
        if(_peripheral.state==CBPeripheralStateConnected){
            return WYDeviceStateConnected;
        }else if (_peripheral.state==CBPeripheralStateConnecting){
            return WYDeviceStateConnecting;
        }else if (_peripheral.state==CBPeripheralStateDisconnected){
            return WYDeviceStateDisconnected;
        }
    }else{
        return WYDeviceStateDisconnected;
    }
    return WYDeviceStateDisconnected;
}

#pragma mark - CBCentralManager delegate
-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict{
    NSLog(@"willRestoreState:%@",dict);
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
     //NSLog(@" saomiaodao :%@",peripheral.name);
  //  NSLog(@"didDiscoverPeripheral:%@",peripheral.identifier.UUIDString);
//    NSString *rang1=@"SmartKee";
//    NSString *rang2=@"SmartWallit";
//    NSString *rang3=@"SafeWallet";
//    NSString *rang4=@"Exhibition";
//    
//    if([peripheral.name rangeOfString:rang1].location!=NSNotFound ||[peripheral.name rangeOfString:rang2].location!=NSNotFound ||[peripheral.name rangeOfString:rang3].location!=NSNotFound||[peripheral.name rangeOfString:rang4].location!=NSNotFound){
//        if(scanDelete && [scanDelete respondsToSelector:@selector(didDiscoverPeripheral::RSSI:)]){
//            [scanDelete didDiscoverPeripheral:_tag  :peripheral RSSI:RSSI];
//        }
//    }
//
    if(scanDelete && [scanDelete respondsToSelector:@selector(didDiscoverPeripheral::scanData:RSSI:)]){
        [scanDelete didDiscoverPeripheral:_tag :peripheral scanData:advertisementData RSSI:RSSI];
    }
    
    
    //对于有的硬件,没有外设名字,虽然在LightBlue里面扫到的是Unname, 但名字是nil. 这里的限制条件就要更改才能扫描的到.
    
//    if(peripheral.name  ){
    
//    }
    
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
   // NSLog(@"didConnect %d uuid:%@",_tag ,peripheral.identifier.UUIDString);
    
//    if(deviceDelegate && [deviceDelegate respondsToSelector:@selector(didConnect::)]){
//        [deviceDelegate didConnect:_tag :peripheral];
//    }
    NSLog(@"---SDK---- :  didConnectPeripheral, start discover services  tag:%d",_tag);
    
    _peripheral=peripheral;
    _peripheral.delegate=self;
    [_peripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"---SDK---- :  didFailToConnectPeripheral, error %@",error);
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self reset];
    
    
        _deviceStatus=5;
        NSLog(@"---SDK---- :  didDisconnectPeripheral,   tag:%d",_tag);
        
        if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didDisconnect::)]){
            [deviceDelegate didDisconnect:_tag :peripheral];
        }
    
    //不需要这块的重连
    //[self connect];
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //2秒之后检测是否还是连接状态，来决定连接是否稳定了，因为有时候一开始会反复断连
    
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            [NSNOTIC_CENTER postNotificationName:KNotification_BluetoothPowerOff object:[NSNumber numberWithInt:_tag]];
            
//            if(scanDelete&& [scanDelete respondsToSelector:@selector(bluetoohPowerOff)]){
//                [scanDelete bluetoohPowerOff];
//            }
            break;
        case CBCentralManagerStatePoweredOn:
            [NSNOTIC_CENTER postNotificationName:KNotification_BluetoothPowerOn object:[NSNumber numberWithInt:_tag]];
            
//            if(scanDelete&& [scanDelete respondsToSelector:@selector(bluetoohPowerOn)]){
//                [scanDelete bluetoohPowerOn];
//            }
//
            break;
        default:
            break;
    }
    
}

#pragma mark - CBCentralManager delegate


#pragma mark - peripheral delegate

-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    if(deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetRssi:::)]){
        [deviceDelegate didGetRssi:_tag :[peripheral.RSSI intValue] :_peripheral];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (!error)
    {
        [WYDevice cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkSuccess:) object:peripheral];
        [self performSelector:@selector(checkSuccess:) withObject:peripheral  afterDelay:1.0];
            
            for (CBService *aService in peripheral.services)
            {
                NSLog(@"---------didDiscoverServices-- = %@   tag:%d",aService.UUID,_tag);
                // Discovers the characteristics for a given service
                if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
                {
                    [peripheral discoverCharacteristics:nil forService:aService];
                }
                
                if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
                {
                    [peripheral discoverCharacteristics:nil forService:aService];
                }
                
                
            }
        
    }else{
         NSLog(@"---SDK---- :  didDiscoverServices, error %@",error);
    }
    
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if(!error){
        
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]){
            
            NSLog(@"QQQQQ aChar:%@",service.characteristics);
            
            for (CBCharacteristic *BChar in service.characteristics)
            {
                if ([BChar.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]]){
                    
                    [peripheral setNotifyValue:YES forCharacteristic:BChar];
                    versionChar = BChar;
                    
                }else if ([BChar.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]){
                    [peripheral setNotifyValue:YES forCharacteristic:BChar];
                    editionChar = BChar;
                    
                }else if ([BChar.UUID isEqual:[CBUUID UUIDWithString:@"FF03"]]){
                
                    [peripheral setNotifyValue:YES forCharacteristic:BChar];
                    macChar = BChar;
                    
                }
                
            }
        }
        
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]]){
            
            NSLog(@"QQQQ aChar:%@",service.characteristics);
            
            for (CBCharacteristic *aChar in service.characteristics)
            {
                NSLog(@" aChar:%@",aChar.UUID.UUIDString);
                
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FEE2"]]){
                    
                    [peripheral setNotifyValue:YES forCharacteristic:aChar];
                    keyAChar = aChar;
                    hasKeyFunction = YES;
                    
                }else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FEE3"]]){
                    [peripheral setNotifyValue:YES forCharacteristic:aChar];
                    SensorChar = aChar;
                    hasKeyFunction = YES;
                    
                }else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FEE4"]]){
                    [peripheral setNotifyValue:YES forCharacteristic:aChar];
                    AccelerationChar = aChar;
                    hasKeyFunction = YES;
                    
                }
                
            }
        }
        
        
    }else{
        NSLog(@"---SDK---- :  didDiscoverCharacteristics, error %@",error);
    }
}


//上报值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (!error){
       // NSLog(@"设备%d收到数据：%@    uuid:%@",_tag,characteristic.value,characteristic.UUID);
            
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FEE2"]])
            {//获取到密钥信息
                if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetKeyData:::)])
                {
                    
                    [deviceDelegate didGetKeyData:_tag :characteristic.value :_peripheral];
                    
                }
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]){
                if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetEditionCharData:::)])
                {
                    
                    [deviceDelegate didGetEditionCharData:_tag :characteristic.value :_peripheral];
                    
                }
                
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]]){
                if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetVersionCharData:::)])
                {
                    
                    [deviceDelegate didGetVersionCharData:_tag :characteristic.value :_peripheral];
                    
                }
                
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FEE3"]]){
                
                if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetSensorData:::)])
                {
                    
                    [deviceDelegate didGetSensorData:_tag :characteristic.value :_peripheral];
                    
                }
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FEE4"]]){//盒子的Mac地址
                
                if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetMacStringCharData:::)])
                {
                    
                    [deviceDelegate didGetMacStringCharData:_tag :characteristic.value :_peripheral];
                    
                }
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF03"]]){
                
                if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetBurglarCharData:::)])
                {
                    
                    [deviceDelegate didGetBurglarCharData:_tag :characteristic.value :_peripheral];
                    
                }
            }
        
        
        
    }
    else{
        NSLog(@"设备收到数据：error");
        
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
   //NSLog(@"didWriteValueForCharacteristic :%@   %@",characteristic.UUID.UUIDString,[self dataToString:characteristic.value]);
    
    if (instructionsArray.count != 0) {
        [instructionsArray removeObjectAtIndex:0];
    }
    
    if (instructionsArray.count == 0) {
      //  NSLog(@"已经传完了");
        
    }else{
        
        [self sendKeyValue:instructionsArray[0]];
        
    }
    
}


#pragma mark - peripheral delegate
//检测连接是否稳定
-(void)checkSuccess:(CBPeripheral *)peripheral{
    if( peripheral.state==CBPeripheralStateConnected){
        
            NSLog(@"检测设备%d 已经连接稳定  ",_tag);
            _deviceStatus=2;
            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didConnect::)])
            {
                [deviceDelegate didConnect:_tag :peripheral];
            }
        
    }
}

//写操作
-(void)sendKeyValue:(NSData *)data{
    if(_peripheral.state==CBPeripheralStateConnected&& keyAChar){
        NSLog(@"send Key char : %@",data);
        NSLog(@"send Key char : %@",keyAChar);
        
        [_peripheral writeValue:data forCharacteristic:keyAChar type:CBCharacteristicWriteWithResponse];
    }
}

-(void)sendUpgrateValue:(NSData *)data{
    if(_peripheral.state==CBPeripheralStateConnected&& upgradeChar){
        NSLog(@"send Key char : %@",data);
        NSLog(@"send Key char : %@",upgradeChar);
        
        [_peripheral writeValue:data forCharacteristic:upgradeChar type:CBCharacteristicWriteWithResponse];
    }
}

//读操作
-(void)sendAccelerationValue{
    
    if(AccelerationChar==nil){
        NSLog(@"editionChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;
        
    }
    
    [_peripheral readValueForCharacteristic: AccelerationChar];
    
}


-(float)sendOADData:(NSData *)data{
    
    runningOAD=YES;
    
    nBlocks=0;
    nBytes=0;
    iBlocks=0;
    iBytes=0;
    
    imageFile=data;
    
    unsigned char imageFileData[imageFile.length];
    [imageFile getBytes:imageFileData];
    
    uint8_t requestData[OAD_IMG_HDR_SIZE + 2 + 2]; // 12Bytes  (8+2+2)
    img_hdr_t imgHeader;
    
    memcpy(&imgHeader, &imageFileData[0 + OAD_IMG_HDR_OSET], sizeof(img_hdr_t));// (0+2)
    memcpy(&imgHeader, &imageFileData[0 + OAD_IMG_HDR_OSET], sizeof(img_hdr_t));// (0+2)
    
    requestData[0] = LO_UINT16(imgHeader.ver);
    requestData[1] = HI_UINT16(imgHeader.ver);
    requestData[2] = LO_UINT16(imgHeader.len);
    requestData[3] = HI_UINT16(imgHeader.len);
  //  NSLog(@"Image version = %d, len = %04hx",imgHeader.ver,imgHeader.len);
    memcpy(requestData + 4, &imgHeader.uid, sizeof(imgHeader.uid));// 4位
    
    requestData[OAD_IMG_HDR_SIZE + 0] = LO_UINT16(12);// 8+0
    requestData[OAD_IMG_HDR_SIZE + 1] = HI_UINT16(12);
    requestData[OAD_IMG_HDR_SIZE + 2] = LO_UINT16(15);
    requestData[OAD_IMG_HDR_SIZE + 3] = HI_UINT16(15);

//    // 发送 bin 头文件
//    /* EVERYTHING IS FOUND, WRITE characteristic ! */
//    NSLog(@"sdk oadImageNotifyChar:%@ ",oadImageNotifyChar);
//    [_peripheral writeValue:[NSData dataWithBytes:requestData length:OAD_IMG_HDR_SIZE + 2 + 2] forCharacteristic:oadImageNotifyChar type:CBCharacteristicWriteWithResponse];
    
    
    // 发送 bin 头文件
    /* EVERYTHING IS FOUND, WRITE characteristic ! */
    CBUUID *sUUID = [CBUUID UUIDWithString:@"0xF000FFC0-0451-4000-B000-000000000000"];
    CBUUID *cUUID = [CBUUID UUIDWithString:@"0xF000FFC1-0451-4000-B000-000000000000"];
    
    
    
    
    for ( CBService *service in _peripheral.services )
    {
        if ([service.UUID isEqual:sUUID])
        {
            for ( CBCharacteristic *characteristic in service.characteristics )
            {
                if ([characteristic.UUID isEqual:cUUID])
                {
                    /* EVERYTHING IS FOUND, WRITE characteristic ! */
                  //  NSLog(@"sdk oadImageNotifyChar %@",characteristic);
                    [_peripheral writeValue:[NSData dataWithBytes:requestData length:OAD_IMG_HDR_SIZE + 2 + 2] forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                }
            }
        }
    }
    
    
    nBlocks = imgHeader.len / (OAD_BLOCK_SIZE / HAL_FLASH_WORD_SIZE);// 4
    nBytes  = imgHeader.len * HAL_FLASH_WORD_SIZE;// 4
    
   //  NSLog(@"imgHeader.len = %d, nBlocks = %d, nBytes = %d", imgHeader.len, nBlocks, nBytes);
    // 发送 bin 文件
     [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(programmingTimerTick:) userInfo:nil repeats:NO];
    
    float secondsPerBlock = SEND_PACKAGE_INTERVAL / SEND_PACKAGE_NUMBER;
    return  (float)(nBlocks) * secondsPerBlock ;
}

//#define SEND_PACKAGE_NUMBER         1
//#define SEND_PACKAGE_INTERVAL       0.03

-(void) programmingTimerTick:(NSTimer *)timer
{
    if(!runningOAD) return;
    
    
    
    unsigned char imageFileData[imageFile.length];
    [imageFile getBytes:imageFileData];
    //Prepare Block
    uint8_t requestData[2 + OAD_BLOCK_SIZE];// 2+16
    
    // This block is run 4 times, this is needed to get CoreBluetooth to send consequetive packets in the same connection interval.
    for (int ii = 0; ii < SEND_PACKAGE_NUMBER; ii++)
    {
        
        requestData[0] = LO_UINT16(iBlocks);
        requestData[1] = HI_UINT16(iBlocks);
        
      //  NSLog(@"iBlocks = %d  nBlocks=%d", iBlocks,nBlocks);
        
        memcpy(&requestData[2] , &imageFileData[iBytes], OAD_BLOCK_SIZE);
        
        CBUUID *sUUID = [CBUUID UUIDWithString:@"0xF000FFC0-0451-4000-B000-000000000000"];
        CBUUID *cUUID = [CBUUID UUIDWithString:@"0xF000FFC2-0451-4000-B000-000000000000"];
        
       
    
        
        for ( CBService *service in _peripheral.services )
        {
            if ([service.UUID isEqual:sUUID])
            {
                for ( CBCharacteristic *characteristic in service.characteristics )
                {
                    if ([characteristic.UUID isEqual:cUUID])
                    {
                        /* EVERYTHING IS FOUND, WRITE characteristic ! */
                      //  NSLog(@"sdk  requestChar:%@ ",characteristic);
                        [_peripheral writeValue:[NSData dataWithBytes:requestData length:2 + OAD_BLOCK_SIZE] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                    }
                }
            }
        }

        iBlocks++;
        iBytes += OAD_BLOCK_SIZE;
        
        if(debug){
            float secondsPerBlock = SEND_PACKAGE_INTERVAL / SEND_PACKAGE_NUMBER;
            float secondsLeft = (float)(nBlocks - iBlocks) * secondsPerBlock;
            
            if(deviceDelegate &&[deviceDelegate respondsToSelector:@selector(didGetOADProgress:::)]){
                [deviceDelegate didGetOADProgress:_tag :(iBlocks/(nBlocks*1.0)) :secondsLeft];
            }
        }
       
        if(iBlocks >= nBlocks){
            NSLog(@"OAD 结束");
            if(deviceDelegate &&[deviceDelegate respondsToSelector:@selector(didGetOADProgress:::)]){
                [deviceDelegate didGetOADProgress:_tag :(iBlocks/(nBlocks*1.0)) :0];
            }
            return;
        }else {
           
            if (ii == SEND_PACKAGE_NUMBER-1)
                [NSTimer scheduledTimerWithTimeInterval:SEND_PACKAGE_INTERVAL target:self selector:@selector(programmingTimerTick:) userInfo:nil repeats:NO];
           
        }
    }

}

-(void)startOADMode{
     [self sendSetting:OAD_OPEN];
}

-(void)stopOAD{
    runningOAD=NO;
 
    nBlocks=0;
    nBytes=0;
    iBlocks=0;
    iBytes=0;
    
    imageFile=nil;
}
-(void)setFastOAD:(BOOL)fast{
    
    if(fast){
        SEND_PACKAGE_NUMBER=4;
    }else{
        SEND_PACKAGE_NUMBER=1;
    }

}
-(void)setOADPackageNum:(NSInteger)num{
    SEND_PACKAGE_NUMBER=num;
}
-(void)setOADPackageInterval:(float)interval{
    SEND_PACKAGE_INTERVAL=interval;
}
-(void)setdEBUG:(BOOL)de{
    debug=de;
}
-(NSString *) dataToString: (NSData *) _data
{
    NSMutableString *pStr = [[NSMutableString alloc] initWithCapacity: 1];
    
    UInt8 *p = (UInt8*) [_data bytes];
    NSUInteger len = [_data length];
    for(NSInteger i = 0; i < len; i ++)
    {
        [pStr appendFormat:@"%02X", *(p+i)];
    }
    return pStr;
}

-(void)sendHexstring:(NSString *)string{

//  NSLog(@"DSTRINGA%@",string);
    [instructionsArray removeAllObjects];
    
    float floatStringlength = string.length/40.0;
    int intStringlength = string.length/40;
    
  //  NSLog(@"DSTRINGA%f",floatStringlength);
  //  NSLog(@"DSTRINGA%d",intStringlength);
    if (floatStringlength > intStringlength) {
        
        
        for (int i = 0; i < intStringlength; i++) {
            
            
           NSString *subsection = [string substringWithRange:NSMakeRange(i * 40, 40)];
            
            NSData *data01 = [ConverUtil parseHexStringToByteArray:subsection];
            [instructionsArray addObject:data01];
          //  [self sendKeyValue:data01];
        }
        
       NSString *lastString =  [string substringWithRange:NSMakeRange(intStringlength * 40, string.length - intStringlength * 40)];
        
        NSData *data02 = [ConverUtil parseHexStringToByteArray:lastString];
        [instructionsArray addObject:data02];
        
      //  NSLog(@"DATA%@",instructionsArray);
        
    }else{
    
        NSString *lastString =  [string substringWithRange:NSMakeRange(0, string.length)];
        
        NSData *data02 = [ConverUtil parseHexStringToByteArray:lastString];
        [instructionsArray addObject:data02];
        
     //   NSLog(@"DATA%@",instructionsArray);

        
    }
}

-(BOOL)isConnected{
    return   _deviceStatus>=2 && _deviceStatus<5;
}

@end
