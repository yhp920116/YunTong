//
//  NSBubbleData.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <Foundation/Foundation.h>
#import "EGOImageView.h"

typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;

@interface NSBubbleData : NSObject <EGOImageViewDelegate>

@property (readonly, nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) NSBubbleType type;
@property (assign, nonatomic) NSInteger fileType;
@property (assign, nonatomic) NSInteger audioDuration;
@property (readonly, nonatomic, strong) UIView *view;
@property (readonly, nonatomic) UIEdgeInsets insets;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, copy) NSString *audioFilePath;
@property (nonatomic, copy) NSString *dataID;
@property (nonatomic, strong) UIProgressView *progressView;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;

- (id)initWithAudioPath:(NSString *) audioPath audioTimeLength:(NSInteger) audioTimeLength date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithAudioPath:(NSString *) audioPath audioTimeLength:(NSInteger) audioTimeLength date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithImage:(UIImage *)image  pictureUrl:(NSString *) pictureUrl date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(UIImage *)image  pictureUrl:(NSString *) pictureUrl date:(NSDate *)date type:(NSBubbleType)type;
- (UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself;
@end

