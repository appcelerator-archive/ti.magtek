//
//  NSObject+TLVParser.m
//  MTEMVDemo
//
//  Created by Tam Nguyen on 7/15/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

#import "NSObject+TLVParser.h"

@implementation MTTLV




@end



@implementation NSMutableDictionary (TLVParser)

- (MTTLV*)getTLV:(NSString*)key{
    
    return [self objectForKey:key];
}

- (NSString*) dumpTags
{
    NSString* dump = @"";
    for(NSString *tlvTag in self.allKeys)
    {
        MTTLV* tlv = [self getTLV:tlvTag];
        dump = [NSString stringWithFormat:@"%@[%@] [%d] %@\r\n", dump, tlv.tag, tlv.length, tlv.value];
    }
    return dump;
}

@end


@implementation NSData (TLVParser)

- (NSMutableDictionary*) parseTLVData
{
    NSMutableDictionary* parsedTLVList = [[NSMutableDictionary alloc]init];
    
    if (self != nil)
    {
        int dataLen = (int)self.length;
        
        if (dataLen >= 2)
        {
            NSData* tlvData = [self subdataWithRange:NSMakeRange(2, self.length - 2)];
            
            if (tlvData != nil)
            {
                int iTLV;
                int iTag;
                int iLen;
                BOOL bTag;
                BOOL bMoreTagBytes;
                BOOL bConstructedTag;
                Byte ByteValue;
                int lengthValue;
                
                NSMutableData* tagBytes = nil;
                
                Byte MoreTagBytesFlag1 	= (Byte) 0x1F;
                Byte MoreTagBytesFlag2 	= (Byte) 0x80;
                
                Byte ConstructedFlag 		= (Byte) 0x20;
                
                Byte MoreLengthFlag 		= (Byte) 0x80;
                Byte OneByteLengthMask 	= (Byte) 0x7F;
                
                Byte TagBuffer[50] = {};
                
                bTag = true;
                iTLV = 0;
                
                while (iTLV < tlvData.length)
                {
                    unsigned char *bytePtr = (unsigned char *)[tlvData bytes];
                    ByteValue = bytePtr[iTLV];
                    
                    if (bTag)
                    {
                        // Get Tag
                        iTag = 0;
                        bMoreTagBytes = true;
                        
                        while (bMoreTagBytes && (iTLV < tlvData.length))
                        {
                            unsigned char *bytePtr = (unsigned char *)[tlvData bytes];
                            ByteValue = bytePtr[iTLV];
                            iTLV++;
                            
                            TagBuffer[iTag] = ByteValue;
                            
                            if (iTag == 0)
                            {
                                bMoreTagBytes = ((ByteValue & MoreTagBytesFlag1) == MoreTagBytesFlag1);
                            }
                            else
                            {
                                bMoreTagBytes = ((ByteValue & MoreTagBytesFlag2) == MoreTagBytesFlag2);
                            }
                            
                            iTag++;
                        }
                        
                        tagBytes = [[NSMutableData alloc]init];
                        [tagBytes appendBytes:TagBuffer length:iTag];
                        bTag = false;
                    }
                    else
                    {
                        lengthValue = 0;
                        
                        if ((ByteValue & MoreLengthFlag) == MoreLengthFlag)
                        {
                            int nLengthBytes = (int) (ByteValue & OneByteLengthMask);
                            
                            iTLV++;
                            iLen = 0;
                            
                            while ((iLen < nLengthBytes) && (iTLV < tlvData.length))
                            {
                                unsigned char *bytePtr = (unsigned char *)[tlvData bytes];
                                ByteValue = bytePtr[iTLV];
                                iTLV++;
                                lengthValue = (int) ((lengthValue &
                                                      0x000000FF) << 8) + (int) (ByteValue & 0x000000FF);
                                iLen++;
                            }
                        }
                        else
                        {
                            lengthValue = (int) (ByteValue & OneByteLengthMask);
                            iTLV++;
                        }
                        
                        if (tagBytes != nil && (memcmp([tagBytes bytes], "\x00", tagBytes.length) != 0))
                        {
                            unsigned char *bytePtr = (unsigned char *)[tagBytes bytes];
                            int tagByte = (int)bytePtr[0];
                            
                            bConstructedTag = ((tagByte & ConstructedFlag) == ConstructedFlag);
                            
                            if (bConstructedTag)
                            {
                                MTTLV* map = [[MTTLV alloc]init];
                                map.tag = [HexUtil toHex:tagBytes];
                                map.length = lengthValue;
                                map.value = @"[Container]";
                               // [parsedTLVList addObject:map];
                                [parsedTLVList setObject:map forKeyedSubscript:map.tag];
                            }
                            else
                            {
                                // Primitive									
                                int endIndex = iTLV + lengthValue;
                                
                                if (endIndex > tlvData.length)
                                    endIndex = (int) tlvData.length;
                                
                                NSMutableData* valueBytes = nil;
                                int len = endIndex - iTLV;
                                if (len > 0)
                                {
                                    valueBytes = [[NSMutableData alloc]init];

                                    NSData* subData = [tlvData subdataWithRange:NSMakeRange(iTLV, len)];
                                    [valueBytes appendBytes:[subData bytes] length:len];
                                }
                                
                                MTTLV* tlvMap = [[MTTLV alloc]init];
                                tlvMap.tag = [HexUtil toHex:tagBytes];
                                tlvMap.length = lengthValue;

                                
                                if (valueBytes != nil)
                                {
                                    tlvMap.value = [HexUtil toHex:valueBytes];
                                }
                                else
                                {
                                    tlvMap.value = @"";
                                }
                                

                               // [parsedTLVList addObject:tlvMap];
                                [parsedTLVList setObject:tlvMap forKeyedSubscript:tlvMap.tag];
                                iTLV += lengthValue;
                            }
                        }
                        
                        bTag = true;
                    }    					
                }
            }
        }
    }
    
    return parsedTLVList;
}


@end
