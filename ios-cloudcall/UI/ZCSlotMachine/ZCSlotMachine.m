
#import <QuartzCore/QuartzCore.h>

#import "ZCSlotMachine.h"

#define SHOW_BORDER 0

static BOOL isSliding = NO;
static const NSUInteger kMinTurn = 50;
static NSString * const keyPath = @"position.y";

/********************************************************************************************/

@implementation ZCSlotMachine {
@public
    BOOL isError;
 @private
    // UI
    UIImageView *_backgroundImageView;
    UIImageView *_coverImageView;
    UIView *_contentView;
    UIEdgeInsets _contentInset;
    NSMutableArray *_slotScrollLayerArray;
    __block NSMutableArray *completePositionArray;
    
    // Data
    NSArray *_slotResults;
    NSArray *_currentSlotResults;
    int slotcount;
    __weak id<ZCSlotMachineDataSource> _dataSource;
}

#pragma mark - View LifeCycle

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_backgroundImageView];
        
        _contentView = [[UIView alloc] initWithFrame:frame];
#if SHOW_BORDER
        _contentView.layer.borderColor = [UIColor blueColor].CGColor;
        _contentView.layer.borderWidth = 1;
#endif
        
        [self addSubview:_contentView];
        
        _coverImageView = [[UIImageView alloc] initWithFrame:frame];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_coverImageView];
        
        _slotScrollLayerArray = [NSMutableArray array];
        
        _slotResults = [NSArray arrayWithObjects:
                         [NSNumber numberWithInteger:0],
                         [NSNumber numberWithInteger:1],
                         [NSNumber numberWithInteger:2], nil];
        
        self.singleUnitDuration = 0.14f;
        
        _contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

#pragma mark - Properties Methods

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImageView.image = backgroundImage;
}

- (void)setCoverImage:(UIImage *)coverImage {
    _coverImageView.image = coverImage;
}

- (UIEdgeInsets)contentInset {
    return _contentInset;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    
    CGRect viewFrame = self.frame;
    
    _contentView.frame = CGRectMake(_contentInset.left, _contentInset.top, viewFrame.size.width - _contentInset.left - _contentInset.right, viewFrame.size.height - _contentInset.top - _contentInset.bottom);
}

- (NSArray *)slotResults {
    return _slotResults;
}

- (void)setSlotResults:(NSArray *)slotResults {
    if (!isSliding) {
        _slotResults = slotResults;
        
        if (!_currentSlotResults) {
            NSMutableArray *currentSlotResults = [NSMutableArray array];
            for (int i = 0; i < [slotResults count]; i++) {
                [currentSlotResults addObject:[NSNumber numberWithUnsignedInteger:0]];
            }
            _currentSlotResults = [NSArray arrayWithArray:currentSlotResults];
        }
    }
}

- (id<ZCSlotMachineDataSource>)dataSource {
    return _dataSource;
}

- (void)setDataSource:(id<ZCSlotMachineDataSource>)dataSource {
    _dataSource = dataSource;
    
    [self reloadData];
}

- (void)reloadData {
    if (self.dataSource) {
        if ([_contentView.layer.sublayers count] != 0)
        {
            for (CALayer *containerLayer in _contentView.layer.sublayers) {
                [containerLayer removeFromSuperlayer];
            }
        }

        _slotScrollLayerArray = [NSMutableArray array];
        
        NSUInteger numberOfSlots = [self.dataSource numberOfSlotsInSlotMachine:self];
        CGFloat slotSpacing = 0;
        if ([self.dataSource respondsToSelector:@selector(slotSpacingInSlotMachine:)]) {
            slotSpacing = [self.dataSource slotSpacingInSlotMachine:self];
        }
        
        CGFloat slotWidth = _contentView.frame.size.width / numberOfSlots;
        if ([self.dataSource respondsToSelector:@selector(slotWidthInSlotMachine:)]) {
            slotWidth = [self.dataSource slotWidthInSlotMachine:self];
        }
        
        for (int i = 0; i < numberOfSlots; i++) {
            CGFloat y = 0;
            CALayer *slotContainerLayer = [[CALayer alloc] init];
            if ([self.dataSource respondsToSelector:@selector(slotContainerLayer_y:)]) {
                y = [self.dataSource slotContainerLayer_y:self];
            }
            
            slotContainerLayer.frame = CGRectMake(i * (slotWidth + slotSpacing), y, slotWidth, _contentView.frame.size.height);
            slotContainerLayer.masksToBounds = YES;
            
            CALayer *slotScrollLayer = [[CALayer alloc] init];
            slotScrollLayer.frame = CGRectMake(0, 0, slotWidth, _contentView.frame.size.height);
#if SHOW_BORDER
            slotScrollLayer.borderColor = [UIColor greenColor].CGColor;
            slotScrollLayer.borderWidth = 1;
#endif
            [slotContainerLayer addSublayer:slotScrollLayer];
            
            [_contentView.layer addSublayer:slotContainerLayer];
            
            [_slotScrollLayerArray addObject:slotScrollLayer];
        }
        
        CGFloat singleUnitHeight = _contentView.frame.size.height / 3;
        
        NSArray *slotIcons = [self.dataSource iconsForSlotsInSlotMachine:self];
        NSUInteger iconCount = [slotIcons count];
        
        for (int i = 0; i < numberOfSlots; i++) {
            CALayer *slotScrollLayer = [_slotScrollLayerArray objectAtIndex:i];
            NSInteger scrollLayerTopIndex = - (i + kMinTurn + 3) * iconCount;
            
            for (int j = 0; j > scrollLayerTopIndex; j--) {
                UIImage *iconImage = [slotIcons objectAtIndex:abs(j) % iconCount];
                
                CALayer *iconImageLayer = [[CALayer alloc] init];
                // adjust the beginning offset of the first unit
                NSInteger offsetYUnit = j + i + iconCount;
                iconImageLayer.frame = CGRectMake(0, offsetYUnit * singleUnitHeight, slotScrollLayer.frame.size.width, singleUnitHeight);
                
                iconImageLayer.contents = (id)iconImage.CGImage;
                iconImageLayer.contentsScale = iconImage.scale;
                iconImageLayer.contentsGravity = kCAGravityResizeAspect;
#if SHOW_BORDER
                iconImageLayer.borderColor = [UIColor redColor].CGColor;
                iconImageLayer.borderWidth = 1;
#endif
                
                [slotScrollLayer addSublayer:iconImageLayer];
            }
        }
    }
}

#pragma mark - Public Methods

- (void)startSliding {
    isError = NO;
    
    if (isSliding) {
        return;
    }
    else {
        isSliding = YES;
        
        if ([self.delegate respondsToSelector:@selector(slotMachineWillStartSliding:)]) {
            [self.delegate slotMachineWillStartSliding:self];
        }
        
        NSArray *slotIcons = [self.dataSource iconsForSlotsInSlotMachine:self];
        NSUInteger slotIconsCount = [slotIcons count];
        
        completePositionArray = [NSMutableArray array];
        
        [CATransaction begin];
        
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [CATransaction setDisableActions:YES];
//        [CATransaction setCompletionBlock:^{
//            isSliding = NO;
//            
//            if ([self.delegate respondsToSelector:@selector(slotMachineDidEndSliding:)]) {
//                [self.delegate slotMachineDidEndSliding:self];
//            }
//            
//        }];
        
        for (int i = 0; i < [_slotScrollLayerArray count]; i++) {
            CALayer *slotScrollLayer = [_slotScrollLayerArray objectAtIndex:i];
            
            NSUInteger resultIndex = [[self.slotResults objectAtIndex:i] unsignedIntegerValue];
            NSUInteger currentIndex = [[_currentSlotResults objectAtIndex:i] unsignedIntegerValue];
            
            NSUInteger howManyUnit = (i + kMinTurn) * slotIconsCount + resultIndex - currentIndex;
            CGFloat slideY = howManyUnit * (_contentView.frame.size.height / 3);
            
            CABasicAnimation *slideAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
            slideAnimation.fillMode = kCAFillModeForwards;
            slideAnimation.duration = howManyUnit * self.singleUnitDuration/2;
            slideAnimation.toValue = [NSNumber numberWithFloat:slotScrollLayer.position.y + slideY];
            slideAnimation.removedOnCompletion = NO;
            
            [slotScrollLayer addAnimation:slideAnimation forKey:@"tmp_slideAnimation"];
            
            [completePositionArray addObject:slideAnimation.toValue];
        }
        
        [CATransaction commit];
    }
}

- (void)stopSliding:(NSArray *)slotResultArray andIsError:(BOOL)error
{
    isError = error;
    slotcount = 0;
    NSArray *slotIcons = [self.dataSource iconsForSlotsInSlotMachine:self];
    NSUInteger slotIconsCount = [slotIcons count];
    
    [CATransaction begin];
    
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [CATransaction setDisableActions:YES];
    [CATransaction setCompletionBlock:^{
        isSliding = NO;
        
        if ([self.delegate respondsToSelector:@selector(slotMachineDidEndSliding:)]) {
            [self.delegate slotMachineDidEndSliding:self];
        }
        
    }];
    
    //延迟执行
//        double delayInSeconds = 1;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            for (int i = 0; i < [_slotScrollLayerArray count]; i++) {
                
                CALayer *slotScrollLayer = [_slotScrollLayerArray objectAtIndex:i];
                [slotScrollLayer removeAnimationForKey:@"tmp_slideAnimation"];
                
                NSUInteger resultIndex = [[slotResultArray objectAtIndex:i] unsignedIntegerValue];
                NSUInteger currentIndex = [[_currentSlotResults objectAtIndex:i] unsignedIntegerValue];
                NSUInteger howManyUnit = (i) * slotIconsCount + resultIndex - currentIndex-i;
                CGFloat slideY = howManyUnit * (_contentView.frame.size.height / 3);
                
                CABasicAnimation *slideAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
                slideAnimation.fillMode = kCAFillModeForwards;
                slideAnimation.duration = howManyUnit * self.singleUnitDuration/2;
                slideAnimation.toValue = [NSNumber numberWithFloat:slotScrollLayer.position.y + slideY];
                slideAnimation.removedOnCompletion = NO;
                slideAnimation.delegate = self;
                [slotScrollLayer addAnimation:slideAnimation forKey:@"slideAnimation"];
                
                //code to be executed on the main queue after delay
                [completePositionArray addObject:slideAnimation.toValue];
            }
//        });
    [CATransaction commit];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    slotcount++;
    NSLog(@"stop");
    
    if (isError == NO && [self.delegate respondsToSelector:@selector(slotMachineDidEndEveryColmun:)])
    {
        [self.delegate slotMachineDidEndEveryColmun:slotcount];
    }
}

- (void)animationDidStart:(CAAnimation *)anim
{
    NSLog(@"start");
}

@end
