//
//  MediaCell.h
//  InstagramTestApp
//
//  Created by mac on 08.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+LikeExtension.h"

@interface MediaCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *authorAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorName;
@property (weak, nonatomic) IBOutlet UILabel *likeCounterLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsCounterLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@end
