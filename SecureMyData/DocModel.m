//
//  DocModel.m
//  SecureMyData
//
//  Created by MD on 27.02.16.
//  Copyright © 2016 MD. All rights reserved.
//

#import "DocModel.h"

@implementation DocModel


-(instancetype) initWithName:(NSString*) name {
    
    self = [super init];
    if (self) {
        self.name = name;
    }
    return self;
}


#pragma mark - NSCoping

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if (self) {
        self.name   = [aDecoder decodeObjectForKey:@"name"];
        self.arrayPhotos  = [aDecoder decodeObjectForKey:@"arrayPhotos"];
    }
    return self;
}


-(void) encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:[self name]  forKey:@"name"];
    [aCoder encodeObject:[self arrayPhotos]  forKey:@"arrayPhotos"];
}


@end
