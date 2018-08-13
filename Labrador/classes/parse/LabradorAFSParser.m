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
    AudioStreamBasicDescription _audioStreamBasicDescription ;
}
@property(nonatomic, weak)id<LabradorDataProvider> dataProvider ;
@property(nonatomic, assign)UInt32 dataOffset ;
@property(nonatomic, strong)NSMutableArray<LabradorAudioFrame *> *frames ;
@property(nonatomic, assign)UInt32 frameByteSize ;

- (void)parseForAudioStreamBasicDescription:(AudioStreamBasicDescription)description ;
@end

void LabradorAFSParser_AudioFileStream_PropertyListenerProc(
                                             void *                             inClientData,
                                             AudioFileStreamID                  inAudioFileStream,
                                             AudioFileStreamPropertyID          inPropertyID,
                                             AudioFileStreamPropertyFlags       *ioFlags){
    if(inPropertyID == kAudioFileStreamProperty_DataFormat) {
        LabradorAFSParser *_self_ = (__bridge LabradorAFSParser *)inClientData ;
        AudioStreamBasicDescription asbd ;
        UInt32 size = sizeof(AudioStreamBasicDescription) ;
        AudioFileStreamGetProperty(inAudioFileStream, inPropertyID, &size, &asbd) ;
        [_self_ parseForAudioStreamBasicDescription:asbd] ;
    } else if(inPropertyID == kAudioFileStreamProperty_ReadyToProducePackets) {
        NSLog(@"准备生产音频数据") ;
    }
}
void LabradorAFSParser_AudioFileStream_PacketsProc(
                                    void *                              inClientData,
                                    UInt32                              inNumberBytes,
                                    UInt32                              inNumberPackets,
                                    const void *                        inInputData,
                                    AudioStreamPacketDescription        *inPacketDescriptions){
    NSLog(@"得到音频数据: %u, %u, %@", inNumberBytes, inNumberPackets, [NSThread currentThread]) ;
    LabradorAFSParser *_self_ = (__bridge LabradorAFSParser *)inClientData ;
    NSMutableArray<LabradorAudioPacket *> *tmps = [[NSMutableArray<LabradorAudioPacket *> alloc] init] ;
    for(int i = 0; i < inNumberPackets; i ++) {
        AudioStreamPacketDescription tmp = inPacketDescriptions[i] ;
        LabradorAudioPacket *packet = [[LabradorAudioPacket alloc] initWithAudioData:inInputData
                                                                     descriptions:tmp] ;
        [tmps addObject:packet] ;
    }
    LabradorAudioFrame *frame = [[LabradorAudioFrame alloc] initWithPackets:tmps]  ;
    [_self_.frames addObject: frame];
    _self_.frameByteSize += frame.byteSize ;
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
                                              LabradorAFSParser_AudioFileStream_PropertyListenerProc,
                                              LabradorAFSParser_AudioFileStream_PacketsProc,
                                              kAudioFileMP3Type,
                                              &_audioFileStreamID) ;
        if(status != noErr) {
            NSLog(@"Error: %d", status) ;
            return nil ;
        }
        uint32_t byte_size = 1024 * 32 ;
        void *bytes = malloc(byte_size) ;
        uint32_t read_size = [provider getBytes:bytes size:byte_size offset:0] ;
        status = AudioFileStreamParseBytes(_audioFileStreamID, read_size, bytes, 0) ;
        free(bytes) ;
        self.dataOffset += read_size ;
        if(status != noErr) {
            NSLog(@"Error: %d", status) ;
            return nil ;
        }
    }
    return self;
}
- (void)parseForAudioStreamBasicDescription:(AudioStreamBasicDescription)description {
    _audioStreamBasicDescription = description ;
}

- (AudioStreamBasicDescription)parse {
    return _audioStreamBasicDescription ;
}

- (LabradorAudioFrame *)product:(UInt32)minByteSize {
    if (self.frames.count <= 0) {
        NSLog(@"生产数据:%@", [NSThread currentThread]);
        uint32_t byte_size = LabradorAudioQueueBufferCacheSize  ;
        void *bytes = malloc(byte_size) ;
        uint32_t size = [_dataProvider getBytes:bytes size:byte_size offset:self.dataOffset] ;
        AudioFileStreamParseBytes(_audioFileStreamID, size, bytes, 0) ;
        self.dataOffset += size ;
        free(bytes) ;
    }
    LabradorAudioFrame *frame = self.frames.firstObject ;
    if(frame) {
        [self.frames removeObjectAtIndex:0] ;
        self.frameByteSize -= frame.byteSize ;
    }
    return frame ;
}
@end
