//
//  CommentCell.h
//  InstagramTestApp
//
//  Created by mac on 08.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <InstagramKit.h>

@interface CommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *comment;

- (void)configureCellWithComment:(InstagramComment*)comment;

@end
