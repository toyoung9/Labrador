//
//  LabradorAFSParser.h
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LabradorParse.h"
#import "LabradorDataProvider.h"

@interface LabradorAFSParser : NSObject <LabradorParse>

- (instancetype)init NS_UNAVAILABLE ;;
- (instancetype)init:(id<LabradorDataProvider>)provider ;


@end
