//
//  CommentCell.m
//  InstagramTestApp
//
//  Created by mac on 08.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithComment:(InstagramComment*)comment {
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:comment.user.username attributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:17]}];
    NSAttributedString *commentString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@": %@", comment.text]];
    [attr appendAttributedString:commentString];
    [self.comment setAttributedText:attr];
}

@end
