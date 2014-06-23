//
//  ApiManager.m
//  pumgrana
//
//  Created by Romain Pichot on 09/02/2014.
//  Copyright (c) 2014 Romain Pichot. All rights reserved.
//

#import "ApiManager.h"
#import "Content.h"
#import "Tag.h"

@implementation ApiManager

/**
 * Checks if there are no error with the response
 * @param response Entire response from the API request
 * @return YES if everything is ok
 */
+ (BOOL)checkResponseStatus:(NSDictionary *)response
{
    NSNumber    *status = [response objectForKey:@"status"];

    return ([status isEqual:@200] || [status isEqual:@201] || [status isEqual:@204]);
}

/**
 * Makes a request to the API
 * @todo asynchronous request
 * @todo refresh calls
 * @todo persistance (local db)
 * @param urlParams Parameters for the API url
 * @return The response or nil if it fails
 */
+ (id)getJSONResponse:(NSString *)urlParams
{
    NSString    *urlStr     = API_URL;
    NSURL       *url        = [NSURL URLWithString:[urlStr stringByAppendingString:urlParams]];
    NSError     *urlError   = nil;
    NSData      *data       = [NSData dataWithContentsOfURL:url options:0 error:&urlError];
    
    if (data) {
        NSError     *error      = nil;
        id          response    = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if ([ApiManager checkResponseStatus:response])
            return (response);
    }
    
    return (nil);
}

/**
 * Makes an API call to get all the contents
 * @return An array of Content objects
 */
+ (NSMutableArray *)getContents
{
    NSDictionary    *response   = [ApiManager getJSONResponse:@"/content/list_content/"];
    NSMutableArray  *ret        = [[NSMutableArray alloc] init];
    
    if (response) {
        NSArray *contents   = [response objectForKey:@"contents"];
        
        for (NSDictionary *content in contents) {
            Content *c = [[Content alloc] initFromJson:content];
            [ret addObject:c];
        }
    }
    
    return (ret);
}

/**
 * Makes an API call to get all the tags
 * @return An array of Tag objects
 */
+ (NSMutableArray *)getTags
{
    NSDictionary    *response   = [ApiManager getJSONResponse:@"/tag/list_by_type/CONTENT"];
    NSMutableArray  *ret        = [[NSMutableArray alloc] init];
    
    if (response) {
        NSArray *tags   = [response objectForKey:@"tags"];
        
        for (NSDictionary *tag in tags) {
            Tag *t = [[Tag alloc] initFromJson:tag];
            [ret addObject:t];
        }
    }
    
    return (ret);
}

/**
 * Makes an API call to fill the links of a Content object
 * @param content The content we want the links
 * @param contents The array containing all the contents
 * @return The original Content object
 */
+ (Content *)getContentLinks:(Content *)content contents:(NSMutableArray *)contents
{
    NSString        *url        = @"/link/list_from_content/";
    NSDictionary    *response   = [ApiManager getJSONResponse:[url stringByAppendingFormat:@"%@", content.id]];
    
    if (response) {
        NSArray *linkArray  = [response objectForKey:@"links"];
        
        if (linkArray != (id)[NSNull null]) {
            content.links = [[NSMutableArray alloc] init];
            for (NSDictionary *link in linkArray) {
                NSNumber *id = [link objectForKey:@"content_id"];
        
                for (Content *c in contents) {
                    if ([c.id isEqual:id]) {
                        [content.links addObject:c];
                        break ;
                    }
                }
            }
        }
    }
    
    return (content);
}

/**
 * Returns the tag list of a content
 * @param content The content we want the tags
 * @return Content's tag list
 */
+ (NSMutableArray *)getContentTags:(Content *)content
{
    NSString        *url        = @"/tag/list_from_content/";
    NSDictionary    *response   = [ApiManager getJSONResponse:[url stringByAppendingFormat:@"%@", content.id]];
    NSMutableArray  *tags       = [[NSMutableArray alloc] init];
    
    if (response) {
        NSArray *tagArray  = [response objectForKey:@"tags"];
        
        for (NSDictionary *tag in tagArray) {
            Tag *newTag = [[Tag alloc] initFromJson:tag];
            [tags addObject:newTag];
        }
    }
    
    return (tags);
}

+ (void)updateContent:(Content *)content
{
    NSMutableString *paramTags  = [[NSMutableString alloc] initWithString:@"["];
    NSInteger       index       = 0;
    for (Tag *t in content.tags) {
        if (index > 0)
            [paramTags appendString:@","];
        [paramTags appendFormat:@"\"%@\"", t.id];
        ++index;
    }
    [paramTags appendString:@"]"];
    
    NSString    *params     = [[NSString alloc] initWithFormat:@"{\"content_id\":\"%@\",\"title\":\"%@\",\"text\":\"%@\",\"tags_id\":%@}", content.id, content.title, content.text, paramTags];
    NSData      *postData   = [params dataUsingEncoding:NSUTF8StringEncoding];
    NSString    *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSString    *baseUrl    = API_URL;
    NSString    *url        = [baseUrl stringByAppendingString:@"/content/update"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

+ (void)insertContent:(Content *)content
{
    NSString    *params     = [[NSString alloc] initWithFormat:@"{\"title\":\"%@\", \"summary\":\"%@\", \"text\":\"%@\"}", content.title, content.text, content.text];
    NSData      *postData   = [params dataUsingEncoding:NSUTF8StringEncoding];
    NSString    *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSString    *baseUrl    = API_URL;
    NSString    *url        = [baseUrl stringByAppendingString:@"/content/insert"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

@end
