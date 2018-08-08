//
//  LabradorInnerPlayer.m
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorInnerPlayer.h"

@interface LabradorInnerPlayer()
{
    AudioStreamBasicDescription _audioStreamBasicDescription ;
    AudioQueueRef _aqr;
    UInt32 _bufferByteSize;
    AudioQueueBufferRef buffers[3];
    
    
}
@property(nonatomic, strong)NSCondition *lock ;
@property(nonatomic, strong)NSMutableArray<LabradorAudioDataModel *> *audioDataModels;
@end


void Labrador_AudioQueueOutputCallback(void * __nullable       inUserData,
                                       AudioQueueRef           inAQ,
                                       AudioQueueBufferRef     inBuffer){
    LabradorInnerPlayer *this = (__bridge LabradorInnerPlayer *)inUserData ;
    [this.lock lock] ;
    if(this.audioDataModels.count == 0) {
        [this.lock wait] ;
    }
    LabradorAudioDataModel *audioDataModel = this.audioDataModels.firstObject ;
    memcpy(inBuffer->mAudioData, audioDataModel.audioData.mAudioData, audioDataModel.audioData.mAudioDataByteSize) ;
    inBuffer->mPacketDescriptionCount = audioDataModel.audioData.mPacketDescriptionCount ;
#error
    [this.audioDataModels removeObjectAtIndex:0] ;
    [this.lock unlock] ;
}

@implementation LabradorInnerPlayer

- (void)dealloc
{
    for(int i = 0; i < 3; i ++) {
        AudioQueueFreeBuffer(_aqr, buffers[i]) ;
    }
}
- (instancetype)initWithDescription:(AudioStreamBasicDescription)description
{
    self = [super init];
    if (self) {
        _audioStreamBasicDescription = description ;
        _bufferByteSize = 1024 * 5 ;
        _audioDataModels = [[NSMutableArray<LabradorAudioDataModel *> alloc] init] ;
        _lock = [[NSCondition alloc] init] ;
        [self initializeAudioQueue] ;
    }
    return self;
}

- (void)initializeAudioQueue {
    OSStatus status = AudioQueueNewOutput(&_audioStreamBasicDescription,
                                          Labrador_AudioQueueOutputCallback,
                                          (__bridge void *)self,
                                          CFRunLoopGetCurrent(),
                                          kCFRunLoopCommonModes,
                                          0,
                                          &_aqr);
    if(!status) {
        NSLog(@"AudioQueueNewOutput error: %d", (int)status) ;
        return ;
    }
    for(int i = 0; i < 3; i ++) {
        AudioQueueBufferRef buffer = NULL ;
        status = AudioQueueAllocateBuffer(_aqr, _bufferByteSize, &buffer) ;
        if(!status) {
            NSLog(@"AudioQueueAllocateBuffer error: %d", (int)status) ;
            break ;
        }
        buffer[i] = *buffer ;
        status = AudioQueueEnqueueBuffer(_aqr, buffer, 0, NULL) ;
        if(!status) {
            NSLog(@"AudioQueueEnqueueBuffer error: %d", (int)status) ;
            break ;
        }
        
    }
}

- (void)receiveData:(LabradorAudioDataModel *)audioData {
    [_lock lock] ;
    [_audioDataModels addObject:audioData] ;
    [_lock signal] ;
    [_lock unlock] ;
}

@end
