//
//  ApiManager.h
//  pumgrana
//
//  Created by Romain Pichot on 09/02/2014.
//  Copyright (c) 2014 Romain Pichot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Content.h"

//#define API_URL (@"http://163.5.84.222/api")
//#define API_URL (@"http://pichot.fr:1337")
#define API_URL (@"http://192.168.84.141:8081/api")

@interface ApiManager : NSObject

+ (BOOL)checkResponseStatus:(NSDictionary *)response;
+ (id)getJSONResponse:(NSString *)urlParams;

+ (NSMutableArray *)getContents;
+ (NSMutableArray *)getTags;
+ (Content *)getContentLinks:(Content *)content contents:(NSMutableArray *)contents;
+ (Content *)getContentTags:(Content *)content tags:(NSMutableArray *)tags;
+ (void)updateContent:(Content *)content;
+ (void)insertContent:(Content *)content;

@end
