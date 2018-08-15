//
//  LabradorInnerPlayer.m
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorInnerPlayer.h"
#import "configure.h"


@interface LabradorInnerPlayer()
{
    AudioStreamBasicDescription _audioStreamBasicDescription ;
    AudioQueueRef _aqr;
//    UInt32 _bufferByteSize;
    CFMutableArrayRef _buffers ;
    dispatch_queue_t _playQueue ;
    NSThread *_playThread ;
    NSPort *_playPort ;
    NSRunLoop *_playRunLoop ;
}

@property(nonatomic,weak)id<LabradorInnerPlayerDataProvider> dataProvider ;

- (void)enqueue:(AudioQueueBufferRef)inBuffer;
@end


void Labrador_AudioQueueOutputCallback(void * __nullable       inUserData,
                                       AudioQueueRef           inAQ,
                                       AudioQueueBufferRef     inBuffer){
    NSLog(@"回收音频缓存数据") ;
    LabradorInnerPlayer *this = (__bridge LabradorInnerPlayer *)inUserData ;
    [this enqueue:inBuffer] ;
}

@implementation LabradorInnerPlayer

- (void)dealloc
{
    [_playRunLoop removePort:_playPort forMode:NSRunLoopCommonModes] ;
    [_playThread cancel] ;
    for(int i = 0; i < CFArrayGetCount(_buffers); i ++) {
        AudioQueueFreeBuffer(_aqr, (AudioQueueBufferRef)CFArrayGetValueAtIndex(_buffers, i));
    }
    CFArrayRemoveAllValues(_buffers) ;
}
- (instancetype)initWithDescription:(AudioStreamBasicDescription)description
                           provider:(id<LabradorInnerPlayerDataProvider>)provider
{
    self = [super init];
    if (self) {
        _audioStreamBasicDescription = description ;
        _buffers = CFArrayCreateMutable(CFAllocatorGetDefault(), 0, NULL) ;
        _dataProvider = provider ;
        _playPort = [NSPort port] ;
        _playThread = [[NSThread alloc] initWithTarget:self selector:@selector(initializeAudioQueue) object:nil] ;
        _playThread.name = @"Play & Decode" ;
        [_playThread start] ;
    }
    return self;
}

- (void)initializeAudioQueue {
    _playRunLoop = [NSRunLoop currentRunLoop] ;
    [[NSRunLoop currentRunLoop] addPort:_playPort forMode:NSRunLoopCommonModes] ;
    OSStatus status = AudioQueueNewOutput(&_audioStreamBasicDescription,
                                          Labrador_AudioQueueOutputCallback,
                                          (__bridge void *)self,
                                          NULL,
                                          NULL,
                                          0,
                                          &_aqr);
    if(status != noErr) {
        NSLog(@"AudioQueueNewOutput error: %d", (int)status) ;
        AudioQueueDispose(_aqr, YES) ;
        return ;
    }
    
    for(int i = 0; i < 3; i ++) {
        AudioQueueBufferRef buffer = NULL ;
        status = AudioQueueAllocateBuffer(_aqr, LabradorAudioQueueBufferCacheSize * 2, &buffer) ;
        if(status != noErr) {
            NSLog(@"AudioQueueAllocateBuffer error: %d", (int)status) ;
            break ;
        }
        CFArrayAppendValue(_buffers, buffer) ;
        [self enqueue:buffer] ;
    }
}

- (void)enqueue:(AudioQueueBufferRef)inBuffer {
    LabradorAudioFrame *frame = [self.dataProvider nextFrame] ;
    if(frame) {
        UInt32 offset = 0 ;
        AudioStreamPacketDescription *aspds = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) * frame.packets.count) ;
        for(int i = 0; i < frame.packets.count; i ++) {
            LabradorAudioPacket *packet = frame.packets[i] ;
            memcpy(inBuffer->mAudioData + offset,
                   packet.data,
                   packet.byteSize) ;
            memcpy(aspds + i, packet.packetDescription, sizeof(AudioStreamPacketDescription)) ;
            offset += packet.byteSize ;
        }
        inBuffer->mAudioDataByteSize = offset ;
        inBuffer->mPacketDescriptionCount = (UInt32)frame.packets.count ;
        OSStatus status = AudioQueueEnqueueBuffer(_aqr,
                                                  inBuffer,
                                                 (UInt32)frame.packets.count,
                                                  aspds) ;
        if(status != noErr) {
            NSLog(@"AudioQueueEnqueueBuffer error: %d", (int)status) ;
        }
        free(aspds) ;
        NSLog(@"入队列: %u", offset) ;
        NSLog(@"------------------------------------------------------------------") ;
    } else {
        NSLog(@"未得到音频帧") ;
    }
}

#pragma mark - music control
- (void)play{
    AudioQueueStart(_aqr, NULL) ;
}
- (void)pause {
    AudioQueuePause(_aqr) ;
}
- (void)resume {
    AudioQueueStart(_aqr, NULL) ;
}

@end
