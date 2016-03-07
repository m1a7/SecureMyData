//
//  DocModel.h
//  SecureMyData
//
//  Created by MD on 27.02.16.
//  Copyright © 2016 MD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocModel : NSObject <NSCoding>

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSMutableArray* arrayPhotos;

-(instancetype) initWithName:(NSString*) name;

@end
