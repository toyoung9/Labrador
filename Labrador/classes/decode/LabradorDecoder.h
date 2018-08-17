//
//  LabradorDecoder.h
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LabradorDecodable.h"
#import "LabradorDataProvider.h"

@protocol LabradorDecoderDelegate <LabradorDataProvider>
@end

@interface LabradorDecoder : NSObject <LabradorDecodable>

- (instancetype)init NS_UNAVAILABLE ;;
- (instancetype)init:(id<LabradorDecoderDelegate>)delegate ;

@end
