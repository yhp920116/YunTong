/* Copyright (c) 2011, SkyBroad. All rights reserved.
 *
 * Contact: support@weicall.net
 *       
 * This file is part of SkyBroad WeiCall Project
 *
 */

#import <Foundation/Foundation.h>


typedef enum btn_type_e
{
    TYPE_MAIL_NONE,
    TYPE_MAIL_TO,
    TYPE_WEB_URL
} btn_type_e;

@interface UIUnderlinedButton : UIButton {
    NSString *urlstring;
    btn_type_e type;
}

+ (UIUnderlinedButton*) underlinedButton:(btn_type_e) type;

/*- (void) GotoWebSite;
- (void) Mailto;
- (void) SetMailto:(NSString*)emailaddr;
- (void) SetWebsiteURL:(NSString*)urlstring;*/
@end
