//
//  SocketClient.h
//  SocketDemo
//
//  Created by 周登杰 on 2019/11/1.
//  Copyright © 2019 zdj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketClient : NSObject
+ (void)loadDataFromServerWithURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
