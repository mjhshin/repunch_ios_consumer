//
//  RPPullToRefreshView.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPPullToRefreshView.h"
#import "RPTableView.h"
#import "RepunchUtils.h"

#define DEGREES_TO_RADIANS(x) (x)/180.0*M_PI
#define RADIANS_TO_DEGREES(x) (x)/M_PI*180.0

#define PULL_TO_REFRESH_THRESHOLD 110.0

@interface RPActivityIndicatorBackgroundLayer : CALayer

@property (nonatomic,assign) CGFloat outlineWidth;

- (id)initWithBorderWidth:(CGFloat)width;

@end

@implementation RPActivityIndicatorBackgroundLayer

- (id)init
{
    self = [super init];
    if(self) {
        self.outlineWidth = 2.0f;
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setNeedsDisplay];
    }
    return self;
}

- (id)initWithBorderWidth:(CGFloat)width
{
    self = [super init];
    if(self) {
        self.outlineWidth = width;
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setNeedsDisplay];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    //Draw white circle
    //CGContextSetFillColor(ctx, CGColorGetComponents([UIColor colorWithBlack:1.0 alpha:0.8].CGColor));
    //CGContextFillEllipseInRect(ctx, CGRectInset(self.bounds, self.outlineWidth, self.outlineWidth));

    //Draw circle outline
    //CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.4 alpha:0.9].CGColor);
    //CGContextSetLineWidth(ctx, self.outlineWidth);
    //CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, self.outlineWidth , self.outlineWidth ));
}

- (void)setOutlineWidth:(CGFloat)outlineWidth
{
    _outlineWidth = outlineWidth;
    [self setNeedsDisplay];
}

@end

/*-----------------------------------------------------------------*/

@interface RPPullToRefreshView()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;  //Loading Indicator
@property (nonatomic, strong) RPActivityIndicatorBackgroundLayer *backgroundLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, assign) double progress;

@end

@implementation RPPullToRefreshView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, -PULL_TO_REFRESH_THRESHOLD, 64, 64)];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.borderColor = [RepunchUtils repunchOrangeColor];
    self.borderWidth = 2.0f;
    self.state = RPPullToRefreshStateNone;
	self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
	self.originalTopInset = 64.0f; //status bar (20) + nav bar (44)
	
    //init actitvity indicator
    self.activityIndicatorView =
		[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	self.activityIndicatorView.color = [RepunchUtils darkRepunchOrangeColor];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.frame = self.bounds;
    [self addSubview:_activityIndicatorView];
    
    //init background layer
    RPActivityIndicatorBackgroundLayer *backgroundLayer =
		[[RPActivityIndicatorBackgroundLayer alloc] initWithBorderWidth:self.borderWidth];
    backgroundLayer.frame = self.bounds;
    [self.layer addSublayer:backgroundLayer];
    self.backgroundLayer = backgroundLayer;
    
	//set image
    self.imageIcon = [UIImage imageNamed:@"StarRefresh"];
    
    //init icon layer
    CALayer *imageLayer = [CALayer layer];
    imageLayer.contentsScale = [UIScreen mainScreen].scale;
    imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);
    imageLayer.contents = (id)self.imageIcon.CGImage;
    [self.layer addSublayer:imageLayer];
    self.imageLayer = imageLayer;
    self.imageLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(180), 0, 0, 1);

    //init arc draw layer
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = self.bounds;
    shapeLayer.fillColor = nil;
    shapeLayer.strokeColor = self.borderColor.CGColor;
    shapeLayer.strokeEnd = 0;
    shapeLayer.shadowColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    shapeLayer.shadowOpacity = 0.7;
    shapeLayer.shadowRadius = 20;
    shapeLayer.contentsScale = [UIScreen mainScreen].scale;
    shapeLayer.lineWidth = self.borderWidth;
    shapeLayer.lineCap = kCALineCapRound;
    
    [self.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
}

- (void)styleForStore
{
	self.originalTopInset = 20.0f;
	self.imageIcon = [UIImage imageNamed:@"star_refresh_white"];
	self.borderColor = [UIColor whiteColor];
	self.activityIndicatorView.color = [UIColor whiteColor];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.shapeLayer.frame = self.bounds;
	[self updatePath];
}

- (void)updatePath
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:center
															  radius:20 //(self.bounds.size.width/2 - self.borderWidth)
														  startAngle:M_PI - DEGREES_TO_RADIANS(-90)
															endAngle:M_PI - DEGREES_TO_RADIANS(360-90)
														   clockwise:YES];

    self.shapeLayer.path = bezierPath.CGPath;
}


#pragma mark - ScrollViewInset

- (void)setupScrollViewContentInsetForLoadingIndicator:(RefreshHandler)handler
{
    CGFloat offset = MAX(self.tableView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.tableView.contentInset;
    currentInsets.top = MIN(offset, self.originalTopInset + self.bounds.size.height + 32.0);
    [self setScrollViewContentInset:currentInsets handler:handler];
}

- (void)resetScrollViewContentInset:(RefreshHandler)handler
{
	UIEdgeInsets currentInsets = self.tableView.contentInset;
    currentInsets.top = self.originalTopInset;
    [self setScrollViewContentInset:currentInsets handler:handler];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset handler:(RefreshHandler)handler
{
	[UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|
								UIViewAnimationOptionCurveEaseOut|
								UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.tableView.contentInset = contentInset;
                     }
                     completion:^(BOOL finished) {
                         if(handler)
                             handler();
                     }];
}


#pragma mark - property

- (void)setProgress:(double)progress
{
    static double prevProgress;
    
    if(progress > 1.0) {
        progress = 1.0;
    }
    
    self.alpha = 1.0 * progress;

    if (progress >= 0 && progress <=1.0) {
        //rotation Animation
        CABasicAnimation *animationImage = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animationImage.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180*prevProgress - 180)];
        animationImage.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(180*progress - 180)];
        animationImage.duration = 0.15;
        animationImage.removedOnCompletion = NO;
        animationImage.fillMode = kCAFillModeForwards;
        [self.imageLayer addAnimation:animationImage forKey:@"animation"];

        //strokeAnimation
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = [NSNumber numberWithFloat:((CAShapeLayer *)self.shapeLayer.presentationLayer).strokeEnd];
        animation.toValue = [NSNumber numberWithFloat:progress];
        animation.duration = 0.35 + 0.25*(fabs([animation.fromValue doubleValue] - [animation.toValue doubleValue]));
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		//[self.shapeLayer removeAllAnimations];
        [self.shapeLayer addAnimation:animation forKey:@"animation"];
        
    }
    _progress = progress;
    prevProgress = progress;
}

- (void)setLayerOpacity:(CGFloat)opacity
{
    self.imageLayer.opacity = opacity;
    self.backgroundLayer.opacity = opacity;
    self.shapeLayer.opacity = opacity;
}

- (void)setLayerHidden:(BOOL)hidden
{
    self.imageLayer.hidden = hidden;
    self.shapeLayer.hidden = hidden;
    self.backgroundLayer.hidden = hidden;
}

- (void)setCenter:(CGPoint)center
{
    [super setCenter:center];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
    else if([keyPath isEqualToString:@"contentSize"])
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    else if([keyPath isEqualToString:@"frame"])
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset
{
	static double prevProgress;
    CGFloat yOffset = contentOffset.y;
    self.progress = ((yOffset + self.originalTopInset)/-PULL_TO_REFRESH_THRESHOLD);
    
    self.center = CGPointMake(self.center.x, (contentOffset.y + self.originalTopInset)/2);
	
    switch (_state) {
        case RPPullToRefreshStateStopped: //finish
			// NSLog(@"Stoped");
            break;
			
        case RPPullToRefreshStateNone: //detect action
			// NSLog(@"None");
            if(self.tableView.isDragging && yOffset < 0) {
                self.state = RPPullToRefreshStateTriggering;
            }
			break;
			
        case RPPullToRefreshStateTriggering: //progress
			// NSLog(@"trigering");
			if(self.progress >= 1.0) {
				self.state = RPPullToRefreshStateTriggered;
			}
            break;
			
        case RPPullToRefreshStateTriggered: //fire actionhandler
			// NSLog(@"trigered");
            if(self.tableView.dragging == NO && prevProgress > 0.99) {
                [self actionTriggeredState];
            }
            break;
			
        case RPPullToRefreshStateLoading: //wait until stopIndicatorAnimation
			// NSLog(@"loading");
            break;
			
        default:
            break;
    }
    //because of iOS6 KVO performance
    prevProgress = self.progress;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        RPTableView *tableView = (RPTableView *)self.superview;
        if (tableView.showPullToRefresh) {
            if (self.isObserving) {
                //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
                [tableView removeObserver:self forKeyPath:@"contentOffset"];
                [tableView removeObserver:self forKeyPath:@"contentSize"];
                [tableView removeObserver:self forKeyPath:@"frame"];
                self.isObserving = NO;
            }
        }
    }
}

- (void)actionStopState
{
    self.state = RPPullToRefreshStateNone;
	
    [UIView animateWithDuration:0.2
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 self.activityIndicatorView.transform = CGAffineTransformMakeScale(0.1, 0.1);
					 }
					 completion:^(BOOL finished) {
						 self.activityIndicatorView.transform = CGAffineTransformIdentity;
						 [self.activityIndicatorView stopAnimating];
						 [self resetScrollViewContentInset:^{
							 [self setLayerHidden:NO];
							 [self setLayerOpacity:1.0];
						 }];
					 }];
}

- (void)actionTriggeredState
{
    self.state = RPPullToRefreshStateLoading;
    
    [UIView animateWithDuration:0.1
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 [self setLayerOpacity:0.0];
					 }
					 completion:^(BOOL finished) {
						 [self setLayerHidden:YES];
					 }];

    [self.activityIndicatorView startAnimating];
    [self setupScrollViewContentInsetForLoadingIndicator:nil];
	
    if(self.pullToRefreshHandler) {
        self.pullToRefreshHandler();
	}
}


#pragma mark - public method

- (void)stopIndicatorAnimation
{
    [self actionStopState];
}

- (void)manuallyTriggered
{
    [self setLayerOpacity:0.0];

    UIEdgeInsets currentInsets = self.tableView.contentInset;
    currentInsets.top = self.originalTopInset + self.bounds.size.height + 20.0;
    [UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, -currentInsets.top);
					 }
					 completion:^(BOOL finished) {
						 [self actionTriggeredState];
					 }];
}

- (void)setImageIcon:(UIImage *)imageIcon
{
    _imageIcon = imageIcon;
    _imageLayer.contents = (id)_imageIcon.CGImage;
    _imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);

    [self setSize:_imageIcon.size];
}

- (void)setSize:(CGSize) size
{
    CGRect rect = CGRectMake((self.tableView.bounds.size.width - size.width)/2,
                             -size.height, size.width, size.height);
	
    self.frame = rect;
    self.shapeLayer.frame = self.bounds;
    self.activityIndicatorView.frame = self.bounds;
    self.imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);
    
    self.backgroundLayer.frame = self.bounds;
    [self.backgroundLayer setNeedsDisplay];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    
    _backgroundLayer.outlineWidth = _borderWidth;
    [_backgroundLayer setNeedsDisplay];
    
    _shapeLayer.lineWidth = _borderWidth;
    _imageLayer.frame = CGRectInset(self.bounds, self.borderWidth, self.borderWidth);
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    _shapeLayer.strokeColor = _borderColor.CGColor;
}

- (void)setContentInsetTop:(CGFloat)topInset
{
    _originalTopInset = topInset;
}

@end

