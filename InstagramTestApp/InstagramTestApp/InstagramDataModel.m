//
//  InstagramDataModel.m
//  InstagramTestApp
//
//  Created by mac on 07.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import "InstagramDataModel.h"
#import <CoreData+MagicalRecord.h>
#import <InstagramKit.h>
#import "Media.h"

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

- (void)fetchEntities {
    NSArray *entities = [Media MR_findAllSortedBy:@"createdDate" ascending:NO];
    
    for (Media *media in entities) {
        NSDictionary *info = [NSKeyedUnarchiver unarchiveObjectWithData:media.info];
        InstagramMedia *instMedia = [[InstagramMedia alloc]initWithInfo:info];
        [self.feedMediaArray addObject:instMedia];
    }
}

- (void)updateFeedWithMedia:(NSArray*)mediaArray {
    [self.feedMediaArray removeAllObjects];
    [self.feedMediaArray addObjectsFromArray:mediaArray];
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    [Media MR_truncateAllInContext:localContext];
    
    for (InstagramMedia *instMedia in mediaArray) {
        Media *media = [Media MR_createInContext:localContext];
        media.info = instMedia.info;
        media.createdDate = instMedia.createdDate;
    }
    [localContext MR_saveOnlySelfWithCompletion:nil];
}

- (void)removeAllFeedMedia {
    [Media MR_truncateAll];
    [self.feedMediaArray removeAllObjects];
}

@end
