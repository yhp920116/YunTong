//
//  NSBubbleData.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "NSBubbleData.h"
#import <QuartzCore/QuartzCore.h>

#define KFacialSizeWidth 24
#define KFacialSizeHeight 24
#define MAX_WIDTH 210
#define BEGIN_FLAG @"["
#define END_FLAG @"]"

@implementation NSBubbleData

#pragma mark - Properties
@synthesize fileType = _fileType;
@synthesize audioDuration = _audioDuration;
@synthesize date = _date;
@synthesize type = _type;
@synthesize view = _view;
@synthesize insets = _insets;
@synthesize avatar = _avatar;
@synthesize audioFilePath;
@synthesize dataID;
@synthesize progressView;

#pragma mark - Lifecycle

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_date release];
	_date = nil;
    [_view release];
    _view = nil;
    
    self.avatar = nil;
    
    if (progressView) {
        [progressView release];
        progressView = nil;
    }

    [super dealloc];
}
#endif

#pragma mark 根据文字生成视图

//图文混排
-(void)getImageRange:(NSString*)message dataArray:(NSMutableArray*)array
{
    NSRange range = [message rangeOfString: BEGIN_FLAG];
    NSRange range1= [message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0 && (range1.location - range.location) == 4) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1 - range.location)]];
            NSString *str = [message substringFromIndex:range1.location+1];
            [self getImageRange:str dataArray:array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str dataArray:array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
    }
}

-(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    
    [self getImageRange:message dataArray:array];
    
    UIView *returnView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    
    NSArray *data = array;
    
    UIFont *fon = [UIFont systemFontOfSize:15.0];
    
    CGFloat upX = 0;
    CGFloat upY = 3;
    CGFloat X = 0;
    CGFloat Y = 25;
    if (data)
    {
        for (int i=0;i < [data count];i++)
        {
            NSString *str=[data objectAtIndex:i];
//            NSLog(@"str--->%@",str);
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG] && [str length] == 5)
            {
                if (upX >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = MAX_WIDTH;
                    Y += KFacialSizeHeight;
                }
//                NSLog(@"str(image)---->%@",str);
                NSString *imageName = [str substringWithRange:NSMakeRange(1, str.length - 2)];
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
                if (upX+KFacialSizeWidth >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = MAX_WIDTH;
                    Y += KFacialSizeHeight;
                }
                img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [returnView addSubview:img];
                [img release];
                
                upX += KFacialSizeWidth;
                
                if (X < MAX_WIDTH) X = upX;
            }
            else
            {
                for (int j = 0; j < [str length]; j++)
                {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
//                    NSLog(@"%@,%0.1f", temp, upX);
                    if (upX >= MAX_WIDTH)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = MAX_WIDTH;
                        Y += KFacialSizeHeight;
                    }
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(MAX_WIDTH, MAXFLOAT)];
                    if (upX+size.width >= MAX_WIDTH)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = MAX_WIDTH;
                        Y += KFacialSizeHeight;
                    }
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                    la.font = fon;
                    la.text = temp;
                    la.backgroundColor = [UIColor clearColor];
                    [returnView addSubview:la];
                    [la release];
                    upX=upX+size.width;
                    if (X < MAX_WIDTH) {
                        X = upX;
                    }
                }
            }
        }
    }
    returnView.frame = CGRectMake(0, 0, X, Y); //需要将该view的尺寸记下，方便以后使用
//    NSLog(@"sizefit:  %.1f %.1f", X, Y);
    return returnView;
}

#pragma mark - Text bubble

const UIEdgeInsets textInsetsMine = {5, 10, 11, 17};
const UIEdgeInsets textInsetsSomeone = {5, 15, 11, 10};

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithText:text date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithText:text date:date type:type];
#endif    
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = (text ? text : @"");
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
#if !__has_feature(objc_arc)
    [label autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    
//    return [self initWithView:[self bubbleView:text from:YES] date:date type:type insets:insets];
    return [self initWithView:[self assembleMessageAtIndex:text from:YES] date:date type:type insets:insets];
}

#pragma mark - Image bubble

const UIEdgeInsets imageInsetsMine = {10, 11, 11, 15};
const UIEdgeInsets imageInsetsSomeone = {10, 15, 11, 11};

+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:image date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:image date:date type:type];
#endif    
}

- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type
{
    CGSize size = image.size;
    if (size.width > 140)
    {
        size.height /= (size.width / 140);
        size.width = 140;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = image;
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;

    
#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date type:type insets:insets];       
}

+ (id)dataWithImage:(UIImage *)image pictureUrl:(NSString *) pictureUrl date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:image pictureUrl:pictureUrl date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:image pictureUrl:pictureUrl date:date type:type];
#endif
}

- (id)initWithImage:(UIImage *)image  pictureUrl:(NSString *) pictureUrl date:(NSDate *)date type:(NSBubbleType)type
{
    EGOImageView *imageView = [[EGOImageView alloc] initWithPlaceholderImage:image];
    imageView.frame = CGRectMake(0, 0, 100, 100);
    UIImage* anImage = [[EGOImageLoader sharedImageLoader] imageForURL:[NSURL URLWithString:pictureUrl] shouldLoadWithObserver:nil];
    if (anImage)
    {
        imageView.image = anImage;
        CGSize size = anImage.size;
        if (size.width > 140)
        {
            size.height /= (size.width / 140);
            size.width = 140;
        }
        imageView.frame = CGRectMake(0, 0, size.width, size.height);
    }
    else
    {
        imageView.imageURL = [NSURL URLWithString:pictureUrl];
    }
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    imageView.delegate = self;
    
#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
        
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date type:type insets:insets];
}

const UIEdgeInsets audioInsetsMine = {11, 13, 16, 22};
const UIEdgeInsets audioInsetsSomeone = {11, 18, 16, 14};

#pragma mark - Audio Bubble
+ (id)dataWithAudioPath:(NSString *) audioPath audioTimeLength:(NSInteger) audioTimeLength date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
        return [[[NSBubbleData alloc] initWithAudioPath:audioPath audioTimeLength:audioTimeLength date:date type:type] autorelease];
#else
        return [[NSBubbleData alloc] initWithAudioPath:audioPath audioTimeLength:audioTimeLength date:date type:type];
#endif
}

- (id)initWithAudioPath:(NSString *) audioPath audioTimeLength:(NSInteger) audioTimeLength date:(NSDate *)date type:(NSBubbleType)type
{
    self.audioFilePath = audioPath;
    self.audioDuration = audioTimeLength;
    
    UIImageView *micImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    if (type == BubbleTypeMine)
    {
        micImageView.image = [UIImage imageNamed:@"micMine"];
    }
    else
    {
        micImageView.image = [UIImage imageNamed:@"micSomeone"];
    }
    
#if !__has_feature(objc_arc)
    [micImageView autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? audioInsetsMine : audioInsetsSomeone);
    return [self initWithView:micImageView date:date type:type insets:insets];
}


#pragma mark - Custom view bubble

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithView:view date:date type:type insets:insets] autorelease];
#else
    return [[NSBubbleData alloc] initWithView:view date:date type:type insets:insets];
#endif    
}

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets  
{
    self = [super init];
    if (self)
    {
#if !__has_feature(objc_arc)
        _view = [view retain];
        _date = [date retain];
#else
        _view = view;
        _date = date;
#endif
        _type = type;
        _insets = insets;
    }
    return self;
}
                
#pragma mark - EGOImageViewDelegate
- (void)imageViewLoadedImage:(EGOImageView*)imageView
{
    CGSize imageSize = [[imageView image] size];
    
    if (imageSize.width > 140)
    {
        imageSize.height /= (imageSize.width / 140);
        imageSize.width = 140;
    }
    
    imageView.frame = CGRectMake(0, 0, imageSize.width , imageSize.height);
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageLoadedNotification" object:imageView.image];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:dataID forKey:@"dataID"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageLoadedNotification" object:imageView.image userInfo:userInfo];
}
                
@end
