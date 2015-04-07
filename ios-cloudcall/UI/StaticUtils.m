//
//  StaticUtils.m
//  CloudCall
//
//  Created by CloudCall on 13-8-9.
//  Copyright (c) 2013年 CloudTech. All rights reserved.
//

#import "StaticUtils.h"
#include "encryption.h"

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                                 float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


@implementation StaticUtils

+ (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size
{
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, 10, 10);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *roundRect = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    return roundRect;
}

+ (NSString *)transformMessageViewDate:(NSString *)messageDate
{

    //转成成nsdate
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *msgDate = [df dateFromString:messageDate];
    [df release];

    NSString *dateString = [[[NSString alloc] init] autorelease];
    //目前的年月日
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger nowDay = [nowComponents day];
    NSInteger nowMonth= [nowComponents month];
    NSInteger nowYear= [nowComponents year];
    
    //消息的年月日
    NSDateComponents *messageComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:msgDate];
    NSInteger messageDay = [messageComponents day];
    NSInteger messageMonth= [messageComponents month];
    NSInteger messageYear= [messageComponents year];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (nowYear==messageYear && nowMonth==messageMonth && nowDay==messageDay)
    {
        dateFormatter.dateFormat = @"aHH:mm";
        dateString = [dateFormatter stringFromDate:msgDate];
    }
    else if (nowYear==messageYear && nowMonth==messageMonth && (nowDay-1)==messageDay)
    {
        dateFormatter.dateFormat = @"aHH:mm";
        dateString = [NSString stringWithFormat:@"昨天 %@", [dateFormatter stringFromDate:msgDate]];
    }
    else if (nowYear==messageYear && nowMonth==messageMonth && (nowDay-2)>=messageDay)
    {
        dateFormatter.dateFormat = [NSString stringWithFormat:@"%@月%@日",messageMonth>9?@"MM":@"M",  messageDay>9?@"dd":@"d"];
        dateString = [dateFormatter stringFromDate:msgDate];
    }
    else if (nowYear>messageYear || (nowYear==messageYear && nowMonth>messageMonth))
    {
        dateFormatter.dateFormat = [NSString stringWithFormat:@"yyyy年%@月%@日",messageMonth>9?@"MM":@"M",  messageDay>9?@"dd":@"d"];
        dateString = [dateFormatter stringFromDate:msgDate];
    }
    [dateFormatter release];
    
    return dateString;
}

+ (NSString *)transformIMChatViewDate:(NSDate *)messageDate
{
    //转成成nsdate
    NSDate *msgDate = messageDate;
    
    NSString *dateString = [[[NSString alloc] init] autorelease];
    //目前的年月日
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger nowDay = [nowComponents day];
    NSInteger nowMonth= [nowComponents month];
    NSInteger nowYear= [nowComponents year];
    
    //消息的年月日
    NSDateComponents *messageComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:msgDate];
    NSInteger messageDay = [messageComponents day];
    NSInteger messageMonth= [messageComponents month];
    NSInteger messageYear= [messageComponents year];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (nowYear==messageYear && nowMonth==messageMonth && nowDay==messageDay)
    {
        dateFormatter.dateFormat = @"aHH:mm";
        dateString = [dateFormatter stringFromDate:msgDate];
    }
    else if (nowYear==messageYear && nowMonth==messageMonth && (nowDay-1)==messageDay)
    {
        dateFormatter.dateFormat = @"aHH:mm";
        dateString = [NSString stringWithFormat:@"昨天 %@", [dateFormatter stringFromDate:msgDate]];
    }
    else if (nowYear>messageYear ||
             (nowYear==messageYear && nowMonth>messageMonth) ||
             (nowYear==messageYear && nowMonth==messageMonth && (nowDay-2)>=messageDay))
    {
        dateFormatter.dateFormat = [NSString stringWithFormat:@"yyyy-%@-%@ aHH:mm",messageMonth>9?@"MM":@"M",  messageDay>9?@"dd":@"d"];
        dateString = [dateFormatter stringFromDate:msgDate];
    }
    [dateFormatter release];
    
    return dateString;
}


+ (BOOL)haveSimCard
{
    return ![CTSIMSupportGetSIMStatus() isEqualToString:kCTSIMSupportSIMStatusNotInserted];
}

#pragma mark Encrypt
+ (void)encryptSetup
{
    EncryptSetup();
}
@end
