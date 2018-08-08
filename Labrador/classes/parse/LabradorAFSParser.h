//
//  LabradorAFSParser.h
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LabradorParseProtocol.h"
#import "LabradorDataProviderProtocol.h"

@interface LabradorAFSParser : NSObject <LabradorParseProtocol>

- (instancetype)init NS_UNAVAILABLE ;;
- (instancetype)init:(id<LabradorDataProviderProtocol>)provider ;


@end
