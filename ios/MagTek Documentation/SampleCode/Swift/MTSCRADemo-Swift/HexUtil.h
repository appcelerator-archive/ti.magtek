//
//  HexUtil.h
//  HexUtil
//
//  Created by Tam Nguyen on 5/5/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HexUtil : NSObject

+ (NSString *) toHex:(NSData *)aData;
+ (NSString *)toHex:(NSData *)data offset:(uint)offset len:(NSUInteger)len;
+ (NSData *)getBytesFromHexString:(NSString*)strIn;
@end