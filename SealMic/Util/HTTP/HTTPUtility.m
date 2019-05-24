//
//  HTTPUtility.m
//  SealMeeting
//
//  Created by LiFei on 2019/2/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "HTTPUtility.h"
#import <AFNetworking/AFNetworking.h>
NSString *const BASE_URL = @"Your Server URL";

static AFHTTPSessionManager *manager;

@implementation HTTPUtility

+ (AFHTTPSessionManager *)sharedHTTPManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [AFHTTPSessionManager manager];
        manager.completionQueue = dispatch_queue_create("cn.rongcloud.seal.httpqueue", DISPATCH_QUEUE_SERIAL);
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.validatesDomainName = NO;
        securityPolicy.allowInvalidCertificates = YES;
        manager.securityPolicy = securityPolicy;
        manager.requestSerializer.HTTPShouldHandleCookies = YES;
        ((AFJSONResponseSerializer *)manager.responseSerializer).removesKeysWithNullValues = YES;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    });
    return manager;
}

+ (void)requestWithHTTPMethod:(HTTPMethod)method
                    URLString:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                     response:(void (^)(HTTPResult *))responseBlock {
    AFHTTPSessionManager *manager = [HTTPUtility sharedHTTPManager];
    NSString *url = [BASE_URL stringByAppendingPathComponent:URLString];
    
    switch (method) {
        case HTTPMethodGet: {
            [manager GET:url
              parameters:parameters
                progress:nil
                 success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                     if (responseBlock) {
                         responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                     }
                 }
                 failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                     NSLog(@"GET url is %@, error is %@", URLString, error.localizedDescription);
                     if (responseBlock) {
                         responseBlock([[self class] httpFailureResult:task]);
                     }
                 }];
            break;
        }
            
        case HTTPMethodHead: {
            [manager HEAD:url
               parameters:parameters
                  success:^(NSURLSessionDataTask *_Nonnull task) {
                      if (responseBlock) {
                          responseBlock([[self class] httpSuccessResult:task response:nil]);
                      }
                  }
                  failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                      NSLog(@"HEAD url is %@, error is %@", URLString, error.localizedDescription);
                      if (responseBlock) {
                          responseBlock([[self class] httpFailureResult:task]);
                      }
                  }];
            break;
        }
            
        case HTTPMethodPost: {
            [manager POST:url
               parameters:parameters
                 progress:nil
                  success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                      if (responseBlock) {
                          responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                      }
                  }
                  failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                      NSLog(@"POST url is %@, error is %@", URLString, error.localizedDescription);
                      if (responseBlock) {
                          responseBlock([[self class] httpFailureResult:task]);
                      }
                  }];
            break;
        }
            
        case HTTPMethodPut: {
            [manager PUT:url
              parameters:parameters
                 success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                     if (responseBlock) {
                         responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                     }
                 }
                 failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                     NSLog(@"PUT url is %@, error is %@", URLString, error.localizedDescription);
                     if (responseBlock) {
                         responseBlock([[self class] httpFailureResult:task]);
                     }
                 }];
            break;
        }
            
        case HTTPMethodDelete: {
            [manager DELETE:url
                 parameters:parameters
                    success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                        if (responseBlock) {
                            responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                        }
                    }
                    failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                        NSLog(@"DELETE url is %@, error is %@", URLString, error.localizedDescription);
                        if (responseBlock) {
                            responseBlock([[self class] httpFailureResult:task]);
                        }
                    }];
            break;
        }
            
        default:
            break;
    }
}


+ (HTTPResult *)httpSuccessResult:(NSURLSessionDataTask *)task response:(id)responseObject {
    HTTPResult *result = [[HTTPResult alloc] init];
    result.httpCode = ((NSHTTPURLResponse *)task.response).statusCode;

    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        result.errorCode = [responseObject[@"errCode"] integerValue];
        result.message = responseObject[@"errMsg"];
        result.detail = responseObject[@"errDetail"];
        result.content = responseObject[@"data"];
        result.success = (result.errorCode == ErrorCodeSuccess);
        if (!result.success) {
            NSLog(@"%@, {%@}", task.currentRequest.URL, result);
        }
    } else {
        result.success = NO;
    }

    return result;
}

+ (HTTPResult *)httpFailureResult:(NSURLSessionDataTask *)task {
    HTTPResult *result = [[HTTPResult alloc] init];
    result.success = NO;
    result.httpCode = ((NSHTTPURLResponse *)task.response).statusCode;
    result.errorCode = ErrorCodeHTTPFailure;
    result.detail = NSLocalizedStringFromTable(@"HTTPFailure", @"SealMeeting", nil);
    NSLog(@"%@, {%@}", task.currentRequest.URL, result);
    return result;
}

+ (void)setAuthHeader:(NSString *)auth {
    [[HTTPUtility sharedHTTPManager].requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
}

@end
