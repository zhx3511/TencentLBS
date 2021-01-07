//
//  TencentMap.h
//  dingwei
//
//  Created by chenlei on 2020/12/28.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

NS_ASSUME_NONNULL_BEGIN

@interface TencentMap : CDVPlugin
- (void)getTencentLocation:(CDVInvokedUrlCommand*)command;

@end

NS_ASSUME_NONNULL_END
