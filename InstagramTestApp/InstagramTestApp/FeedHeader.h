//
//  FeedHeader.h
//  InstagramTestApp
//
//  Created by mac on 08.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedHeader : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *authorAvatar;
@property (weak, nonatomic) IBOutlet UILabel *authorName;

@end
