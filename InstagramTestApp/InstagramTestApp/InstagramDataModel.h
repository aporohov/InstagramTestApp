//
//  InstagramDataModel.h
//  InstagramTestApp
//
//  Created by mac on 07.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstagramDataModel : NSObject

@property (nonatomic, copy) NSMutableArray *feedMediaArray;

+ (InstagramDataModel*)sharedInstance;
- (void)fetchEntities;
- (void)updateFeedWithMedia:(NSArray*)mediaArray;
- (void)removeAllFeedMedia;

@end
