//
//  LabradorAFSParser.m
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorAFSParser.h"
#import <AudioToolbox/AudioToolbox.h>
#import "LabradorAudioPacket.h"
#import "configure.h"
@interface LabradorAFSParser()
{
    AudioFileStreamID _audioFileStreamID ;
    LabradorAudioInformation _audioInformation ;
    
}
@property(nonatomic, weak)id<LabradorDataProvider> dataProvider ;
@property(nonatomic, assign)UInt32 dataOffset ;
@property(nonatomic, strong)NSMutableArray<LabradorAudioFrame *> *frames ;
@property(nonatomic, assign)UInt32 frameByteSize ;
@property(nonatomic, assign)float duration;
@property(nonatomic, assign)SInt64 startOffset;
@property(nonatomic, assign)UInt32 bitRate ;
@property(nonatomic, assign)UInt64 totalByteSize ;


- (void)parseAudioFileStreamWithPropertyID:(AudioFilePropertyID)pid ;
- (void)parseAudioPacketWithInNumberBytes:(UInt32)inNumberBytes
                          inNumberPackets:(UInt32)inNumberPackets
                              inInputData:(const void *)inInputData
                     inPacketDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions ;
@end

NS_INLINE void _GetAudioFileStreamPropertyValue(AudioFileStreamID sid, AudioFileStreamPropertyID spid, void *pointer, UInt32 size) {
    AudioFileStreamGetProperty(sid, spid, &size, pointer) ;
}
/*
 AudioStreamBasicDescription description ;
 SInt64 dataOffset ;
 UInt64 audioDataByteCount ;
 UInt32 bitRate ;
 UInt64 audioDataPacketCount ;
 float duration ;
 */
NS_INLINE void _PrintLabradorAudioInformation(LabradorAudioInformation information){
    NSLog(@"") ;
    NSLog(@"*******************************************************") ;
    NSLog(@"") ;
    NSLog(@"-------------------- 音频文件信息 -----------------------") ;
    NSLog(@"时长: %f", information.duration) ;
    NSLog(@"比特率: %u", information.bitRate) ;
    NSLog(@"音频起始位置: %lld", information.dataOffset) ;
    NSLog(@"音频文件大小: %lld", information.audioDataByteCount + information.dataOffset) ;
    NSLog(@"音频包总数: %lld", information.audioDataPacketCount) ;
    NSLog(@"") ;
    NSLog(@"*******************************************************") ;
    NSLog(@"") ;
}

NS_INLINE void _PropertyListenerProc(void *                             inClientData,
                                     AudioFileStreamID                  inAudioFileStream,
                                     AudioFileStreamPropertyID          inPropertyID,
                                     AudioFileStreamPropertyFlags       *ioFlags){
    LabradorAFSParser *this = (__bridge LabradorAFSParser *)inClientData ;
    [this parseAudioFileStreamWithPropertyID:inPropertyID] ;
}
NS_INLINE void _PacketsProc(void *                              inClientData,
                            UInt32                              inNumberBytes,
                            UInt32                              inNumberPackets,
                            const void *                        inInputData,
                            AudioStreamPacketDescription        *inPacketDescriptions){
    NSLog(@"得到音频数据: %u, %u, %@", inNumberBytes, inNumberPackets, [NSThread currentThread]) ;
    LabradorAFSParser *this = (__bridge LabradorAFSParser *)inClientData ;
    [this parseAudioPacketWithInNumberBytes:inNumberBytes inNumberPackets:inNumberPackets inInputData:inInputData inPacketDescriptions:inPacketDescriptions] ;
}


@implementation LabradorAFSParser

- (instancetype)init:(id<LabradorDataProvider>)provider
{
    self = [super init];
    if (self) {
        NSAssert(provider != NULL, @"LABAudioDataProviderProtocol can't be NULL.") ;
        self.frameByteSize = 0 ;
        self.dataProvider = provider ;
        self.dataOffset = 0 ;
        self.frames = [[NSMutableArray<LabradorAudioFrame *> alloc] initWithCapacity:10] ;
        OSStatus status = AudioFileStreamOpen((__bridge void *)self,
                                              _PropertyListenerProc,
                                              _PacketsProc,
                                              kAudioFileMP3Type,
                                              &_audioFileStreamID) ;
        if(status != noErr) {
            NSLog(@"Error: %d", status) ;
            return nil ;
        }
        uint32_t byte_size = LabradorAudioHeaderInputSize ;
        void *bytes = malloc(byte_size) ;
        NSUInteger read_size = [provider getBytes:bytes size:byte_size offset:0] ;
        status = AudioFileStreamParseBytes(_audioFileStreamID, (UInt32)read_size, bytes, 0) ;
        free(bytes) ;
        self.dataOffset += (UInt32)read_size ;
        if(status != noErr) {
            NSLog(@"Error: %d", status) ;
            return nil ;
        }
    }
    return self;
}

- (void)parseAudioFileStreamWithPropertyID:(AudioFilePropertyID)pid {
    switch (pid) {
        case kAudioFileStreamProperty_DataFormat:
            _GetAudioFileStreamPropertyValue(_audioFileStreamID, pid, &_audioInformation.description, sizeof(AudioStreamBasicDescription)) ;
            break;
        case kAudioFileStreamProperty_ReadyToProducePackets:
        {
            _audioInformation.duration = _audioInformation.audioDataByteCount * 8 / _audioInformation.bitRate ;
            if(self.dataProvider) {
                [self.dataProvider receiveContentLength:_audioInformation.audioDataByteCount + _audioInformation.dataOffset] ;
            }
            _PrintLabradorAudioInformation(_audioInformation) ;
        }
            break ;
        case kAudioFileStreamProperty_DataOffset:
            _GetAudioFileStreamPropertyValue(_audioFileStreamID, pid, &_audioInformation.dataOffset, sizeof(SInt64)) ;
            break ;
        case kAudioFileStreamProperty_AudioDataByteCount:
            _GetAudioFileStreamPropertyValue(_audioFileStreamID, pid, &_audioInformation.audioDataByteCount, sizeof(UInt64)) ;
            break ;
        case kAudioFileStreamProperty_BitRate:
            _GetAudioFileStreamPropertyValue(_audioFileStreamID, pid, &_audioInformation.bitRate, sizeof(UInt32)) ;
            break ;
        case kAudioFileStreamProperty_AudioDataPacketCount:
            _GetAudioFileStreamPropertyValue(_audioFileStreamID, pid, &_audioInformation.audioDataPacketCount, sizeof(UInt64)) ;
            break ;
        default:
            break;
    }
}

- (void)parseAudioPacketWithInNumberBytes:(UInt32)inNumberBytes
                          inNumberPackets:(UInt32)inNumberPackets
                              inInputData:(const void *)inInputData
                     inPacketDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions {
    NSMutableArray<LabradorAudioPacket *> *tmps = [[NSMutableArray<LabradorAudioPacket *> alloc] init] ;
    for(int i = 0; i < inNumberPackets; i ++) {
        AudioStreamPacketDescription tmp = inPacketDescriptions[i] ;
        LabradorAudioPacket *packet = [[LabradorAudioPacket alloc] initWithAudioData:inInputData
                                                                        descriptions:tmp] ;
        [tmps addObject:packet] ;
    }
    LabradorAudioFrame *frame = [[LabradorAudioFrame alloc] initWithPackets:tmps]  ;
    [self.frames addObject: frame];
    self.frameByteSize += frame.byteSize ;
}

- (LabradorAudioFrame *)product {
    if (self.frames.count <= 0) {
        NSUInteger byte_size = LabradorAudioQueueBufferCacheSize  ;
        void *bytes = malloc(byte_size) ;
        NSUInteger size = [_dataProvider getBytes:bytes size:byte_size offset:self.dataOffset] ;
        AudioFileStreamParseBytes(_audioFileStreamID, (UInt32)size, bytes, 0) ;
        self.dataOffset += (UInt32)size ;
        free(bytes) ;
    }
    LabradorAudioFrame *frame = self.frames.firstObject ;
    if(frame) {
        [self.frames removeObjectAtIndex:0] ;
        self.frameByteSize -= frame.byteSize ;
    }
    return frame ;
}

- (LabradorAudioInformation)audioInformation {
    return _audioInformation ;
}

@end
