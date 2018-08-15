//
//  LABAudioPlayer.h
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LabradorAudioPlayer_Status){
    LabradorAudioPlayer_Status_Stop,
    LabradorAudioPlayer_Status_Playing,
    LabradorAudioPlayer_Status_Pause,
};

@class LabradorAudioPlayer ;
@protocol LabradorAudioPlayerDelegate <NSObject>
- (void)labradorAudioPlayerPrepared:(LabradorAudioPlayer *)player ;
@end

@interface LabradorAudioPlayer : NSObject
@property (nonatomic, weak)id<LabradorAudioPlayerDelegate> delegate ;
@property (nonatomic, assign)LabradorAudioPlayer_Status status ;
@property (nonatomic, assign)NSInteger cacheStatus ;
- (void)prepare;
- (void)play ;
- (void)pause ;
- (void)resume ;

@end

NS_ASSUME_NONNULL_END
