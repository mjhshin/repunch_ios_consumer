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
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *keyFrames;
@property (nonatomic, strong) UIImage *rotationImage;
@end

@implementation RPSpinner


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        static const NSUInteger numberOfFrames = 10;

        self.keyFrames = [NSMutableArray arrayWithCapacity:numberOfFrames];

        for (NSInteger i = 1; i <= numberOfFrames; i++) {
            NSString *imageName = [NSString stringWithFormat:@"RefreshImage_%i.tiff", i];
            [self.keyFrames addObject:[UIImage imageNamed:imageName]];
        }

        self.rotationImage = [UIImage imageNamed:@"RefreshRotatingImage.png"];
        [self setImageNamed:self.rotationImage];
    }
    return self;
}

- (void)startAnimating
{
    if (self.isAnimating) {
        return;
    }
    _isAnimating = YES;

    self.imageView.image = self.rotationImage;
    self.hidden = NO;
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];

    rotationAnimation.fromValue =  @(DegreesToRadians(0));
    rotationAnimation.toValue = @(DegreesToRadians(360));
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

    NSInteger index = (fillingPercent / 100) * (self.keyFrames.count -1);

    UIImage *image = self.keyFrames[index];
    self.imageView.image = image ;

}

- (void)setHideWhenFinish:(BOOL)hideWhenFinish
{
    _hideWhenFinish = hideWhenFinish;

    if (!self.isAnimating) {
        self.hidden = hideWhenFinish;
    }
}

- (void)setImageNamed:(UIImage *)image
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

    self.imageView.image = image;
}


@end
