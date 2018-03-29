//
//  KSWebImageProtocol.h
//  SOIOEC
//
//  Created by sulier_J on 2014/3/25.
//  Copyright © 2014年 sulier_J. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef void (^KSImageManagerProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

typedef void (^KSImageManagerCompletionBlock)(UIImage * _Nullable image, NSURL * _Nullable url, BOOL success, NSError * _Nullable error);

@protocol KSImageManager <NSObject>

- (void)setImageForImageView:(nullable UIImageView *)imageView
                     withURL:(nullable NSURL *)imageURL
                 placeholder:(nullable UIImage *)placeholder
                    progress:(nullable KSImageManagerProgressBlock)progress
                  completion:(nullable KSImageManagerCompletionBlock)completion;

- (void)cancelImageRequestForImageView:(nullable UIImageView *)imageView;

- (UIImage *_Nullable)imageFromMemoryForURL:(nullable NSURL *)url;

@end
