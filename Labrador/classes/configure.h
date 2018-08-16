//
//  configure.h
//  Labrador
//
//  Created by legendry on 2018/8/13.
//  Copyright © 2018 legendry. All rights reserved.
//

#ifndef configure_h
#define configure_h

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

#endif /* configure_h */
