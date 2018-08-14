//
//  LABDownloader.m
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorDownloader.h"
#import "NSString+Extensions.h"

@interface LabradorDownloader()<NSURLSessionDelegate, NSURLSessionDataDelegate>
{
    NSString *_urlString ;
    NSString *_path ;
    NSUInteger _start ;
    NSUInteger _length ;
    NSURLSession *_session ;
    NSOperationQueue *_operationQueue ;
    NSUInteger _callBackDataLength ;
    NSMutableData *_data ;
}
@end

@implementation LabradorDownloader

#pragma mark - initialize

- (instancetype)initWithURLString:(NSString * _Nonnull)urlString start:(NSUInteger)start length:(NSUInteger)length
{
    self = [super init];
    if (self) {
        _urlString = urlString ;
        _path = [_urlString cachePath] ;
        _start = start ;
        _length = length ;
        _callBackDataLength = 0 ;
        _data = [[NSMutableData alloc] init] ;
        NSLog(@"准备开始下载: %@", [_urlString cachePath]) ;
        [self initializeURLSession] ;
    }
    return self;
}

- (NSUInteger)startLocation {
    return _start ;
}
- (NSUInteger)length {
    return _length ;
}

#pragma mark -
- (void)initializeURLSession {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration] ;
    configuration.timeoutIntervalForRequest = 30.0f ;
    configuration.timeoutIntervalForResource = 30.0f ;
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:_operationQueue] ;
}

- (void)start{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlString]] ;
//    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"] ;
//    request.HTTPMethod = @"GET" ;
    NSString *rangString = [NSString stringWithFormat:@"bytes=%ld-%ld", _start,(_start + _length - 1)] ;
    [request setValue:rangString forHTTPHeaderField:@"Range"] ;
    NSLog(@"==============================================================") ;
    NSLog(@"即将下载的范围: %@", rangString) ;
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request] ;
    NSLog(@"%@", task) ;
    [task resume] ;
}

#pragma mark - NSURLSessionDelegate


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"didReceiveResponse completionHandler: %@", response.allHeaderFields) ;
    completionHandler(NSURLSessionResponseAllow) ;
    
//    if(self.delegate && _start == 0) {
//        NSLog(@"ContentLength: %lld", [response expectedContentLength]) ;
//        [self.delegate receiveContentLength:[response expectedContentLength]] ;
//    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    if(!data || data.length == 0) return ;
    [_data appendData:data] ;
    NSLog(@"接受到数据: %ld, %ld", _data.length, data.length) ;
    if(self.delegate && _data.length >= 1024) {
        NSUInteger tmpCallBackLength = (_data.length - _callBackDataLength) / 1024 * 1024 ;
        NSLog(@"数据大于1024,回调数据:%ld-%ld",_callBackDataLength, tmpCallBackLength) ;
        [self.delegate receiveData:[_data subdataWithRange:NSMakeRange(_callBackDataLength, tmpCallBackLength)] start:_callBackDataLength] ;
        _callBackDataLength += tmpCallBackLength ;
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if(self.delegate) {
        [self.delegate receiveData:[_data subdataWithRange:NSMakeRange(_callBackDataLength, _data.length - _callBackDataLength)] start:_callBackDataLength] ;
        _callBackDataLength = _data.length ;
        NSLog(@"数据接受完成:%ld-%ld", _start, _data.length) ;
        [self.delegate completed] ;
        NSLog(@"==============================================================") ;
    }
}

@end
