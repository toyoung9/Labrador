//
//  LABAudioPlayer.h
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "configure.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LabradorAudioPlayerPlayStatus){
    //stop
    LabradorAudioPlayerPlayStatusStop = 1,
    //playing
    LabradorAudioPlayerPlayStatusPlaying,
    //pause
    LabradorAudioPlayerPlayStatusPause,
    //preparing for play
    LabradorAudioPlayerPlayStatusPreparing,
    //ready for play
    LabradorAudioPlayerPlayStatusPrepared,
};

@class LabradorAudioPlayer ;
@protocol LabradorAudioPlayerDelegate <NSObject>
@optional
- (void)labradorAudioPlayerPrepared:(LabradorAudioPlayer *)player ;
- (void)labradorAudioPlayerWithError:(NSError *)error player:(LabradorAudioPlayer *)player ;
- (void)labradorAudioPlayerDidFinishPlaying:(LabradorAudioPlayer *)player successfully:(BOOL)successfully ;
@end

@interface LabradorAudioPlayer : NSObject
@property (nonatomic, weak)id<LabradorAudioPlayerDelegate> delegate ;
@property (nonatomic, assign)LabradorAudioPlayerPlayStatus playStatus ;
@property (nonatomic, assign)LabradorCacheMappingStatus loadingStatus ;

- (void)prepare;
- (void)play ;
- (void)pause ;
- (void)resume ;

@end

NS_ASSUME_NONNULL_END
