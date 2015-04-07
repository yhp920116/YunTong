/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import "UIUnderlinedButton.h"

@implementation UIUnderlinedButton

+ (UIUnderlinedButton*) underlinedButton:(btn_type_e) type {
    UIUnderlinedButton* button = [[UIUnderlinedButton alloc] init];
    button->type = type;
    return [button autorelease];
}

- (void) drawRect:(CGRect)rect {
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender + 1;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
    
    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);
}
/*
- (void) GotoWebSite {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstring]];
}

- (void) Mailto {
    NSString* a = [@"mailto:" stringByAppendingFormat:(urlstring)];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:a]];
}

- (void) SetMailto:(NSString*)emailaddr {
    urlstring = emailaddr;
}

- (void) SetWebsiteURL:(NSString*)urlstr {
    urlstring = urlstr;
}
*/

@end