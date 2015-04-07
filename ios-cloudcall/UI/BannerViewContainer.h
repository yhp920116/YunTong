//
//  BannerViewContainer.h
//  WeiCall
//
//  Created by Vincent on 12-5-9.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

@protocol BannerViewContainer <NSObject>
@required
- (void)showBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated;
- (void)hideBannerView:(NSObject *)bannerView adtype:(int)type animated:(BOOL)animated;
@end