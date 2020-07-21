//
//  RCMicHTTPUtility.m
//  SealMic
//
//  Created by LiFei on 2019/2/25.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCMicHTTPUtility.h"
#import <AFNetworking/AFNetworking.h>
#import "RCMicMacro.h"

NSString *const RCMicUserNotLoginNotification = @"RCMicUserNotLoginNotification";
static AFHTTPSessionManager *manager;

@implementation RCMicHTTPUtility

+ (AFHTTPSessionManager *)sharedHTTPManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [AFHTTPSessionManager manager];
        manager.completionQueue = dispatch_queue_create("cn.rongcloud.seal.httpqueue", DISPATCH_QUEUE_SERIAL);
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.validatesDomainName = NO;
        securityPolicy.allowInvalidCertificates = YES;
        manager.securityPolicy = securityPolicy;
        ((AFJSONResponseSerializer *)manager.responseSerializer).removesKeysWithNullValues = YES;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        RCMicLog(@"demo server: %@",BASE_URL);
    });
    return manager;
}

+ (void)requestWithHTTPMethod:(RCMicHTTPMethod)method
                    URLString:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                     response:(void (^)(RCMicHTTPResult *))responseBlock {
    AFHTTPSessionManager *manager = [RCMicHTTPUtility sharedHTTPManager];
    NSString *url = [BASE_URL stringByAppendingPathComponent:URLString];
    
    switch (method) {
        case RCMicHTTPMethodGet: {
            [manager GET:url
              parameters:parameters
                progress:nil
                 success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                     if (responseBlock) {
                         responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                     }
                 }
                 failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                     RCMicLog(@"GET url is %@, error is %@", URLString, error.localizedDescription);
                     if (responseBlock) {
                         responseBlock([[self class] httpFailureResult:task]);
                     }
                 }];
            break;
        }
            
        case RCMicHTTPMethodHead: {
            [manager HEAD:url
               parameters:parameters
                  success:^(NSURLSessionDataTask *_Nonnull task) {
                      if (responseBlock) {
                          responseBlock([[self class] httpSuccessResult:task response:nil]);
                      }
                  }
                  failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                      RCMicLog(@"HEAD url is %@, error is %@", URLString, error.localizedDescription);
                      if (responseBlock) {
                          responseBlock([[self class] httpFailureResult:task]);
                      }
                  }];
            break;
        }
            
        case RCMicHTTPMethodPost: {
            [manager POST:url
               parameters:parameters
                 progress:nil
                  success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                      if (responseBlock) {
                          responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                      }
                  }
                  failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                      RCMicLog(@"POST url is %@, error is %@", URLString, error.localizedDescription);
                      if (responseBlock) {
                          responseBlock([[self class] httpFailureResult:task]);
                      }
                  }];
            break;
        }
            
        case RCMicHTTPMethodPut: {
            [manager PUT:url
              parameters:parameters
                 success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                     if (responseBlock) {
                         responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                     }
                 }
                 failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                     RCMicLog(@"PUT url is %@, error is %@", URLString, error.localizedDescription);
                     if (responseBlock) {
                         responseBlock([[self class] httpFailureResult:task]);
                     }
                 }];
            break;
        }
            
        case RCMicHTTPMethodDelete: {
            [manager DELETE:url
                 parameters:parameters
                    success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                        if (responseBlock) {
                            responseBlock([[self class] httpSuccessResult:task response:responseObject]);
                        }
                    }
                    failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                        RCMicLog(@"DELETE url is %@, error is %@", URLString, error.localizedDescription);
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


+ (RCMicHTTPResult *)httpSuccessResult:(NSURLSessionDataTask *)task response:(id)responseObject {
    RCMicHTTPResult *result = [[RCMicHTTPResult alloc] init];
    result.httpCode = ((NSHTTPURLResponse *)task.response).statusCode;

    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        result.errorCode = [responseObject[@"code"] integerValue];
        result.message = responseObject[@"msg"];
        result.content = responseObject[@"data"];
        result.success = (result.errorCode == RCMicHTTPCodeSuccess);
        if (!result.success) {
            RCMicLog(@"%@, {%@}", task.currentRequest.URL, result);
            //用户未登录或缓存的 auth 信息失效后需要重新登录
            if (result.errorCode == RCMicHTTPCodeErrInvalidAuth) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RCMicUserNotLoginNotification object:nil];
            }
        }
    } else {
        result.success = NO;
    }

    return result;
}

+ (RCMicHTTPResult *)httpFailureResult:(NSURLSessionDataTask *)task {
    RCMicHTTPResult *result = [[RCMicHTTPResult alloc] init];
    result.success = NO;
    result.httpCode = ((NSHTTPURLResponse *)task.response).statusCode;
    result.errorCode = RCMicHTTPCodeFailure;
    result.message = @"http request failed";
    RCMicLog(@"%@, {%@}", task.currentRequest.URL, result);
    return result;
}

+ (void)setAuthHeader:(NSString *)auth {
    [[RCMicHTTPUtility sharedHTTPManager].requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
}

+ (NSString *)demoServer {
    return [BASE_URL substringToIndex:BASE_URL.length - 3];
}
@end
