//
//  LabradorAFSParser.m
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorAFSParser.h"
#import <AudioToolbox/AudioToolbox.h>

@interface LabradorAFSParser()
{
    AudioFileStreamID _audioFileStreamID ;
    AudioStreamBasicDescription _audioStreamBasicDescription ;
}
- (void)parseForAudioStreamBasicDescription:(AudioStreamBasicDescription)description ;
@end

void LabradorAFSParser_AudioFileStream_PropertyListenerProc(
                                             void *                            inClientData,
                                             AudioFileStreamID                inAudioFileStream,
                                             AudioFileStreamPropertyID        inPropertyID,
                                                                   AudioFileStreamPropertyFlags *    ioFlags){
    if(inPropertyID == kAudioFileStreamProperty_DataFormat) {
        LabradorAFSParser *_self_ = (__bridge LabradorAFSParser *)inClientData ;
        AudioStreamBasicDescription asbd ;
        UInt32 size = sizeof(AudioStreamBasicDescription) ;
        AudioFileStreamGetProperty(inAudioFileStream, inPropertyID, &size, &asbd) ;
        [_self_ parseForAudioStreamBasicDescription:asbd] ;
    }
}
void LabradorAFSParser_AudioFileStream_PacketsProc(
                                    void *                              inClientData,
                                    UInt32                              inNumberBytes,
                                    UInt32                              inNumberPackets,
                                    const void *                        inInputData,
                                    AudioStreamPacketDescription        *inPacketDescriptions){
    
}


@implementation LabradorAFSParser

- (instancetype)init:(id<LabradorDataProviderProtocol>)provider
{
    self = [super init];
    if (self) {
        NSAssert(provider != NULL, @"LABAudioDataProviderProtocol can't be NULL.") ;
        OSStatus status = AudioFileStreamOpen((__bridge void *)self,
                                              LabradorAFSParser_AudioFileStream_PropertyListenerProc,
                                              LabradorAFSParser_AudioFileStream_PacketsProc,
                                              kAudioFileMP3Type,
                                              &_audioFileStreamID) ;
        if(status != noErr) {
            NSLog(@"Error: %d", status) ;
            return nil ;
        }
        uint32_t byte_size = 1024 * 5 ;
        void *bytes = malloc(byte_size) ;
        uint32_t read_size = [provider getBytes:bytes size:byte_size offset:0] ;
        status = AudioFileStreamParseBytes(_audioFileStreamID, read_size, bytes, kAudioFileStreamParseFlag_Discontinuity) ;
        free(bytes) ;
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

@end
