//
//  SocketClient.m
//  SocketDemo
//
//  Created by 周登杰 on 2019/11/1.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "SocketClient.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <netdb.h>

@implementation SocketClient

+ (void)loadDataFromServerWithURL:(NSURL *)url {
    NSString *host = [url host];
    NSNumber *port = [url port];
    
    
    // create socket
    int socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
    if (socketFileDescriptor == -1) {
        [self networkFailedWithErrorMessage:@"failed to create socket."];

        return;
    }
    
    //get IP address from host,通过DNS查找域名对应的IP地址
    struct hostent *remoteHostEnt = gethostbyname([host UTF8String]);
    if (remoteHostEnt == NULL) {
        close(socketFileDescriptor);
                
        [self networkFailedWithErrorMessage:@"unable to resolve the hostname of the warehouse server."];

        return;
    }
    
    struct in_addr *remoteInAddr = (struct in_addr*)remoteHostEnt->h_addr_list[0];
    
    // set the socket paramters
    struct sockaddr_in socketParameters;
    socketParameters.sin_family = AF_INET;
    socketParameters.sin_addr = *remoteInAddr;
    socketParameters.sin_port = htons([port intValue]);
    
    // connet the socket
    int ret = connect(socketFileDescriptor, (struct sockaddr *)&socketParameters, sizeof(socketParameters));
    if (ret == -1) {
        close(socketFileDescriptor);
        [self networkFailedWithErrorMessage:[NSString stringWithFormat:@"failed to connect to %@: %@",host, port]];
        return;
    }
    
    NSLog(@"successed to connect to %@: %@",host, port);

    
    NSMutableData *data = [[NSMutableData alloc] init];
    BOOL waitingForData = YES;
    
    //continually reveive data until we reach the end of the data
    int maxCount = 5;
    int i = 0;
    while (waitingForData && i < maxCount) {
        const char *buffer[1024];
        int length = sizeof(buffer);
        
        //read a buffer's amount of data from the socket;the number of bytes read is returned
        int result = (int)recv(socketFileDescriptor, &buffer, length, 0);
        if (result > 0) {
            [data appendBytes:buffer length:result];
        } else {
            waitingForData = NO;
        }
        ++i;
    }
    
    //close the socket
    close(socketFileDescriptor);

    [self networkSucceedWithData:data];
    
}




+ (void)networkFailedWithErrorMessage:(NSString *)message {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"update UI");
    }];
}

+ (void)networkSucceedWithData:(NSData *)data {
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"result:%@",result);
    }];
}

@end
