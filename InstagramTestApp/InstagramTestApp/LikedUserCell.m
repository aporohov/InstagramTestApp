//
//  LikedUserCell.m
//  InstagramTestApp
//
//  Created by mac on 09.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import "LikedUserCell.h"

@implementation LikedUserCell

- (void)awakeFromNib {
    _userAvatar.layer.cornerRadius = _userAvatar.frame.size.width/2;
    _userAvatar.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
