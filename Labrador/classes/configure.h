//
//  configure.h
//  Labrador
//
//  Created by legendry on 2018/8/13.
//  Copyright © 2018 legendry. All rights reserved.
//

#ifndef configure_h
#define configure_h

#import <AudioToolbox/AudioQueue.h>

#define LabradorAudioQueueBufferCacheSize   1024 * 32
#define LabradorAudioHeaderInputSize        1024 * 10

typedef NS_ENUM(NSInteger, DownloadType){
    DownloadTypeHeader = 1,
    DownloadTypeAudioData = 2,
};

typedef NS_ENUM(NSInteger,LabradorCacheStatus){
    LabradorCacheStatusLoading = 1, //downloading data
    LabradorCacheStatusEnough,//enough cache data
};

struct LabradorAudioInformation{
    AudioStreamBasicDescription description ;
    SInt64 dataOffset ;
    UInt64 audioDataByteCount ;
    UInt32 bitRate ;
    UInt64 audioDataPacketCount ;
    float duration ;
    UInt64 totalSize ;
};
typedef struct LabradorAudioInformation LabradorAudioInformation;


#endif /* configure_h */
