//
//  FeedCell.h
//  InstagramTestApp
//
//  Created by mac on 07.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+LikeExtension.h"

@interface FeedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
