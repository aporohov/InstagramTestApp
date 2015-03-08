//
//  FeedHeader.m
//  InstagramTestApp
//
//  Created by mac on 08.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import "FeedHeader.h"

@implementation FeedHeader

- (void)awakeFromNib {
    _authorAvatar.layer.cornerRadius = _authorAvatar.frame.size.width/2;
    _authorAvatar.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
