//
//  Keychain.h
//  SecureMyData
//
//  Created by MD on 27.02.16.
//  Copyright © 2016 MD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Keychain : NSObject
{
    NSString * service;
    NSString * group;
}
-(id) initWithService:(NSString *) service_ withGroup:(NSString*)group_;

-(NSMutableDictionary*) prepareDict:(NSString *) key;
-(BOOL) insert:(NSString *)key : (NSData *)data;
-(BOOL) update:(NSString*)key :(NSData*) data;
-(BOOL) remove: (NSString*)key;
-(NSData*) find:(NSString*)key;



-(void) saveUsername:(NSString*)user withPassword:(NSString*)pass forServer:(NSString*)server;
-(void) removeAllCredentialsForServer:(NSString*)server;
-(void) getCredentialsForServer:(NSString*)server;

@end
