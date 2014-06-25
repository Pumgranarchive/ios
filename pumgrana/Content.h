//
//  Content.h
//  pumgrana
//
//  Created by Romain Pichot on 17/11/2013.
//  Copyright (c) 2013 Romain Pichot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tag.h"
#import "PartialContentProtocol.h"

@interface Content : NSObject <PartialContentProtocol>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSMutableArray *links;





- (id)initFromJson:(NSDictionary *)json;
- (id)initFromContent:(Content *)content;

- (BOOL)hasTag: (Tag *)tag;

@end
