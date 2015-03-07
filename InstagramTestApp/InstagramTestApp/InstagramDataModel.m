//
//  InstagramDataModel.m
//  InstagramTestApp
//
//  Created by mac on 07.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import "InstagramDataModel.h"

@implementation InstagramDataModel

+ (InstagramDataModel *)sharedInstance {
    static InstagramDataModel *_sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[InstagramDataModel alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _feedMediaArray = [NSMutableArray new];
    }
    return self;
}

@end
