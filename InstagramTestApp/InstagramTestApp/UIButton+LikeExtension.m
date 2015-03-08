//
//  UIButton.m
//  InstagramTestApp
//
//  Created by mac on 08.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import "UIButton+LikeExtension.h"

@implementation UIButton (LikeExtension)

- (void)likeAnimation:(BOOL)isLiked {
    self.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished) {
        [self userHasLiked:isLiked];
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
        }];
    }];
}

- (void)userHasLiked:(BOOL)isLiked {
    if (isLiked)
        [self setBackgroundImage:[UIImage imageNamed:@"like_red"] forState:UIControlStateNormal];
    else
        [self setBackgroundImage:[UIImage imageNamed:@"like_grey"] forState:UIControlStateNormal];
}

@end
