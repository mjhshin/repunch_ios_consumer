//
//  ORVCSpinner.m
//  Spinner
//
//  Created by Emil on 1/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPSpinner.h"
#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface RPSpinner ()
@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation RPSpinner

- (void)startAnimating
{
    if (self.isAnimating) {
        return;
    }
    _isAnimating = YES;

    self.hidden = NO;

    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];

    CGFloat start = self.fillingPercent / 100 * 360;
    CGFloat end = start + 360;

    rotationAnimation.fromValue =  @(DegreesToRadians(start));
    rotationAnimation.toValue = @(DegreesToRadians(end));
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.removedOnCompletion = NO;

    [self.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

}

- (void)stopAnimating
{
    if (!self.isAnimating) {
        return;
    }
    
    _isAnimating = NO;

    [self.imageView.layer removeAnimationForKey:@"rotationAnimation"];

    if (self.hideWhenFinish) {
        self.hidden = YES;
    }
}

- (void)setFillingPercent:(CGFloat)fillingPercent
{
    self.hidden = NO;
    _fillingPercent = fillingPercent;

    CGFloat angle = fillingPercent / 100 * 360;

    [self rotateWithAngle:angle];

}

- (void)setHideWhenFinish:(BOOL)hideWhenFinish
{
    _hideWhenFinish = hideWhenFinish;

    if (!self.isAnimating) {
        self.hidden = hideWhenFinish;
    }
}

- (void)setImageNamed:(NSString *)imageName
{
    if (!self.imageView) {

        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:self.imageView];

        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary *views = @{@"image": self.imageView};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[image]-0-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[image]-0-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:views]];
    }


    self.imageView.image = [UIImage imageNamed:imageName];
}

- (void)rotateWithAngle:(CGFloat)degrees
{
    CALayer *layer = self.imageView.layer;
    layer.transform =  CATransform3DRotate(CATransform3DIdentity, DegreesToRadians(degrees), 0.0f, 0.0f, 1.0f);

}

@end
