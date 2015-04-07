//
//  NSString+Code.m
//  TianyaQing
//
//  Created by gzty1 on 12-3-6.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Code.h"
#import <CommonCrypto/CommonDigest.h> 
#import <zlib.h>
#import "CCGTMBase64.h"

@implementation NSString (Code)

- (NSString*)md5 
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr,strlen(cStr),result);
    NSString* md5str=[[NSString stringWithFormat:
			 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1], result[2], result[3], 
			 result[4], result[5], result[6], result[7],
			 result[8], result[9], result[10], result[11],
			 result[12], result[13], result[14], result[15]] lowercaseString];
	
	return md5str;
}

//手机号码格式化
- (NSString *)phoneNumFormat
{
    NSString * newNum = [self stringByReplacingOccurrencesOfString:@"-" withString:@""];
    newNum = [newNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    newNum = [newNum stringByReplacingOccurrencesOfString:@"(" withString:@""];
    newNum = [newNum stringByReplacingOccurrencesOfString:@")" withString:@""];
    newNum = [newNum stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    newNum = [newNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return newNum;
}

- (BOOL)haveChSymbol
{
    int length = [self length];
    
    for (int i=0; i<length; ++i)
    {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [self substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3)
        {
            return YES;
        }
    }
    return NO;
}

- (NSString *)doCipher:(NSString *)key operation:(CCOperation)encryptOrDecrypt
{
    const void * vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        NSData * EncryptData = [CCGTMBase64 decodeData:[self dataUsingEncoding:NSUTF8StringEncoding]];
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
    }
    else
    {
        NSData * tempData = [self dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [tempData length];
        vplainText = [tempData bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t * bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    // uint8_t ivkCCBlockSize3DES;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES)
    & ~(kCCBlockSize3DES - 1);
    
    bufferPtr = malloc(bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    NSString * initVec = @"init Vec";
    
    const void * vkey = (const void *)[key UTF8String];
    const void * vinitVec = (const void *)[initVec UTF8String];
    
    uint8_t iv[kCCBlockSize3DES];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey, //"123456789012345678901234", //key
                       kCCKeySize3DES,
                       vinitVec, //"init Vec", //iv,
                       vplainText, //plainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    //if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    if (ccStatus == kCCParamError) return @"PARAM ERROR";
    else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
    else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
    else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
    else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
    else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED";
    
    NSString * result;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        result = [[[NSString alloc] initWithData:[NSData
                                                  dataWithBytes:(const void *)bufferPtr
                                                  length:(NSUInteger)movedBytes]
                                        encoding:NSUTF8StringEncoding]
                  autorelease];
    }
    else
    {
        NSData * myData = [NSData dataWithBytes:(const void *)bufferPtr
                                         length:(NSUInteger)movedBytes];
        result = [CCGTMBase64 stringByEncodingData:myData];
    }
    
    //free
    free(bufferPtr);
    
    return result;
}

- (NSString*)tripleDESWithKey:(NSString*)key
{
	return [self tripleDESWithKey:key compress:NO];
}

/**
 *  first,  3des(password,key)
 *  second, turn encryted memory data to Hex data
 */
- (NSString*)tripleDESWithKey:(NSString*)key compress:(BOOL)compress 
{
	NSData *origData = [self dataUsingEncoding:NSUTF8StringEncoding];
	
	NSData *encryptData;
	if (compress) 
	{
		encryptData = [self gzip];
	} 
	else 
	{
		encryptData = origData;
	}
	
	char keyBuffer[kCCKeySize3DES+1];      // room for terminator (unused)
	bzero( keyBuffer, sizeof(keyBuffer) ); // fill with zeroes (for padding)
	
	[key getCString: keyBuffer maxLength: sizeof(keyBuffer) encoding: NSUTF8StringEncoding];
	
	// encrypts in-place, since this is a mutable data object
	size_t numBytesEncrypted = 0;
	
	size_t returnLength = ([encryptData length] + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
	
	char* returnBuffer = malloc(returnLength * sizeof(uint8_t) );
	
	CCCryptorStatus ccStatus = CCCrypt(kCCEncrypt, kCCAlgorithm3DES , kCCOptionPKCS7Padding | kCCOptionECBMode,
									   keyBuffer, kCCKeySize3DES, nil,
									   [encryptData bytes], [encryptData length], 
									   returnBuffer, returnLength,
									   &numBytesEncrypted);
	
	if (ccStatus == kCCParamError) {NSLog(@"PARAM ERROR");}
	else if (ccStatus == kCCBufferTooSmall) {NSLog(@"BUFFER TOO SMALL");}
	else if (ccStatus == kCCMemoryFailure) {NSLog(@"MEMORY FAILURE");}
	else if (ccStatus == kCCAlignmentError) {NSLog(@"ALIGNMENT");}
	else if (ccStatus == kCCDecodeError) {NSLog(@"DECODE ERROR");}
	else if (ccStatus == kCCUnimplemented) {NSLog(@"UNIMPLEMENTED");}
	
	NSMutableString *hexResult=nil;
    
	if(ccStatus == kCCSuccess) 
    {
        hexResult = [[[NSMutableString alloc] init] autorelease];

		char *tmp = (char*)returnBuffer;
		for (int i=0; i<numBytesEncrypted; i++) {
			NSString *aString = [[NSString alloc] initWithFormat:@"%X",(*tmp)&(0xFF)];
			if ([aString length] == 1) {
				[hexResult appendFormat:@"0%@",aString];
			} else {
				[hexResult appendString:aString];
			}
			[aString release];
			tmp++;
		}
	}
    
    free(returnBuffer);
        
    return hexResult;
}

- (NSString*)decodeTripleDESWithKey:(NSString*)key
{
	NSData *origData = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData* decryptData = [self HexStr2CharStr:[origData bytes] length:[origData length]];
	
	char keyBuffer[kCCKeySize3DES+1];      // room for terminator (unused)
	bzero( keyBuffer, sizeof(keyBuffer) ); // fill with zeroes (for padding)
	
	[key getCString: keyBuffer maxLength: sizeof(keyBuffer) encoding: NSUTF8StringEncoding];
	
	// encrypts in-place, since this is a mutable data object
	size_t numBytesEncrypted = 0;
	
	size_t returnLength = ([decryptData length] + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
	
	char* returnBuffer = malloc(returnLength * sizeof(uint8_t) );
	memset((void *)returnBuffer, 0x0, returnLength);
    
	CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt, kCCAlgorithm3DES , kCCOptionPKCS7Padding | kCCOptionECBMode,
									   keyBuffer, kCCKeySize3DES, nil,
									   [decryptData bytes], [decryptData length],
									   returnBuffer, returnLength,
									   &numBytesEncrypted);
	
	if (ccStatus == kCCParamError) {NSLog(@"PARAM ERROR");}
	else if (ccStatus == kCCBufferTooSmall) {NSLog(@"BUFFER TOO SMALL");}
	else if (ccStatus == kCCMemoryFailure) {NSLog(@"MEMORY FAILURE");}
	else if (ccStatus == kCCAlignmentError) {NSLog(@"ALIGNMENT");}
	else if (ccStatus == kCCDecodeError) {NSLog(@"DECODE ERROR");}
	else if (ccStatus == kCCUnimplemented) {NSLog(@"UNIMPLEMENTED");}
	
    if(ccStatus == kCCSuccess)
    {
        NSString *returnString = [NSString stringWithUTF8String:returnBuffer];
        free(returnBuffer);
        return returnString;
    }
    return nil;
}

- (unsigned char)Hex2Char:(char const*)szHex
{
    unsigned char rch = 0;
    for(int i=0; i<2; i++)
    {
        if(*(szHex + i) >='0' && *(szHex + i) <= '9')
            rch = (rch << 4) + (*(szHex + i) - '0');
        else if(*(szHex + i) >='A' && *(szHex + i) <= 'F')
            rch = (rch << 4) + (*(szHex + i) - 'A' + 10);
        else  
            break;  
    }
    return rch;
}

- (NSData*)HexStr2CharStr:(char const*)pszHexStr length:(int)len
{
    int i;
    int retLen=len/2;
    char retCharStr[retLen];      // room for terminator (unused)
	bzero( retCharStr, sizeof(retCharStr) ); // fill with zeroes (for padding)
    for(i=0; i<retLen; i++)
    {
        retCharStr[i] = [self Hex2Char:pszHexStr+2*i];
    }
    return [NSData dataWithBytes:retCharStr length:retLen];
}

- (NSString*) stringWithHexBytes:(const char*)charBuffer length:(int)len {
    static const char hexdigits[] = "0123456789ABCDEF";
    const size_t numBytes = len;
    const char* bytes = charBuffer;
    char *strbuf = (char *)malloc(numBytes * 2 + 1);
    char *hex = strbuf;
    NSString *hexBytes = nil;

    for (int i = 0; i<numBytes; ++i) {
        const unsigned char c = *bytes++;
        *hex++ = hexdigits[(c >> 4) & 0xF];
        *hex++ = hexdigits[(c ) & 0xF];
        }
    *hex = 0;
    hexBytes = [NSString stringWithUTF8String:strbuf];
    free(strbuf);
    return hexBytes;
}

- (NSData*)gzip
{  
	NSData *pUncompressedData = [self dataUsingEncoding:NSUTF8StringEncoding];
	//NSData *pUncompressedData = [str dataUsingEncoding:NSASCIIStringEncoding];
	
    if (!pUncompressedData || [pUncompressedData length] == 0)  {  
        NSLog(@"%s: Error: Can't compress an empty or null NSData object.", __func__);  
        return nil;  
    }  
	
    z_stream zlibStreamStruct;  
    zlibStreamStruct.zalloc    = Z_NULL;  
    zlibStreamStruct.zfree     = Z_NULL; 
    zlibStreamStruct.opaque    = Z_NULL; 
    zlibStreamStruct.total_out = 0;  
    zlibStreamStruct.next_in   = (Bytef*)[pUncompressedData bytes]; 
    zlibStreamStruct.avail_in  = [pUncompressedData length]; 
	
    int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);  
    if (initError != Z_OK)  {  
        NSString *errorMsg = nil;  
        switch (initError)  {  
            case Z_STREAM_ERROR:  
                errorMsg = @"Invalid parameter passed in to function.";  
                break;  
            case Z_MEM_ERROR:  
                errorMsg = @"Insufficient memory.";  
                break;  
            case Z_VERSION_ERROR:  
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";  
                break;  
            default:  
                errorMsg = @"Unknown error code.";  
                break;  
        }  
        NSLog(@"%s: deflateInit2() Error: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);  
        [errorMsg release];  
        return nil;  
    }  
	
    NSMutableData *compressedData = [NSMutableData dataWithLength:[pUncompressedData length] * 1.01 + 12 + 300];  
	
    int deflateStatus;  
    do  {  
		
        zlibStreamStruct.next_out = [compressedData mutableBytes] + zlibStreamStruct.total_out;  
        zlibStreamStruct.avail_out = [compressedData length] - zlibStreamStruct.total_out;  
		
        deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);  
		
    } while ( deflateStatus == Z_OK );        
	
    // Check for zlib error and convert code to usable error message if appropriate  
    if (deflateStatus != Z_STREAM_END)  {  
        NSString *errorMsg = nil;  
        switch (deflateStatus)  {  
            case Z_ERRNO:  
                errorMsg = @"Error occured while reading file.";  
                break;  
            case Z_STREAM_ERROR:  
                errorMsg = @"The stream state was inconsistent (e.g., next_in or next_out was NULL).";  
                break;  
            case Z_DATA_ERROR:  
                errorMsg = @"The deflate data was invalid or incomplete.";  
                break;  
            case Z_MEM_ERROR:  
                errorMsg = @"Memory could not be allocated for processing.";  
                break;  
            case Z_BUF_ERROR:  
                errorMsg = @"Ran out of output buffer for writing compressed bytes.";  
                break;  
            case Z_VERSION_ERROR:  
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";  
                break;  
            default:  
                errorMsg = @"Unknown error code.";  
                break;  
        }  
        NSLog(@"%s: zlib error while attempting compression: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);  
        [errorMsg release];  
		
        // Free data structures that were dynamically created for the stream.  
        deflateEnd(&zlibStreamStruct);  
		
        return nil;  
    }  
    // Free data structures that were dynamically created for the stream.  
    deflateEnd(&zlibStreamStruct);  
    [compressedData setLength: zlibStreamStruct.total_out];  
    //NSLog(@"%s: Compressed data from %d Bytes to %d Bytes", __func__, [pUncompressedData length], [compressedData length]);  
	
    return compressedData;  
}  

- (NSString *)urlEncode 
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);
	return [result autorelease];
}

- (NSString *)urlDecode
{
    NSString *decodeString = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return decodeString;
}

-(int)characterCount
{
    int strlength = 0;
    char* p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) 
	{
        if (*p) 
		{
            p++;
            strlength++;
        }
        else 
		{
            p++;
        }
    }
    return strlength;
}

-(BOOL)isEqualToStringCaseInsensitive:(NSString *)aString
{
    int result = [self compare:aString options:NSCaseInsensitiveSearch];  //可以多个值|运算
    return result==0; 
}

- (NSDictionary *)parametersWithSeparator:(NSString *)separator delimiter:(NSString *)delimiter 
{ 
    NSArray *parameterPairs = [self componentsSeparatedByString:delimiter]; 
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[parameterPairs count]]; 
    for (NSString *currentPair in parameterPairs) 
	{ 
        NSRange range = [currentPair rangeOfString:separator]; 
        if(range.location == NSNotFound) 
            continue; 
        NSString *key = [currentPair substringToIndex:range.location]; 
        NSString *value =[currentPair substringFromIndex:range.location + 1]; 
        [parameters setObject:value forKey:key]; 
    } 
    return parameters; 
} 

@end
