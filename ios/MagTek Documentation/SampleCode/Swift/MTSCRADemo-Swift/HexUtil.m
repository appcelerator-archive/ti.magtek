//
//  HexUtil.m
//  HexUtil
//
//  Created by Tam Nguyen on 5/5/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import "HexUtil.h"


@implementation HexUtil {


}


+ (NSString *)toHex:(NSData *)aData {
    return [HexUtil toHex:aData offset:0 len:aData.length];
}

+ (NSData *)getBytesFromHexString:(NSString*)strIn
{
    const char *chars = [strIn UTF8String];
    int i = 0;
    NSInteger len = strIn.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}


+ (NSString *)toHex:(NSData *)aData offset:(uint)aOffset len:(NSUInteger)aLen {
    NSMutableString *sb = [[NSMutableString alloc] initWithCapacity:aData.length*2];
    uint8_t const *bytes = aData.bytes;
    NSUInteger max = aOffset+aLen;
    for(NSUInteger i=aOffset; i < max; i++) {
        uint8_t b = bytes[i];
        [sb appendFormat:@"%02X", b];
    }
    return sb;
}
@end