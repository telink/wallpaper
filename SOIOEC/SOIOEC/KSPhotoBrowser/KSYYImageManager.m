//
//  KSWebImage.m
//  SOIOEC
//
//  Created by sulier_J on 2014/3/25.
//  Copyright © 2014年 sulier_J. All rights reserved.
//


#import "KSYYImageManager.h"

#if __has_include(<YYWebImage/YYWebImage.h>)
#import <YYWebImage/YYWebImage.h>
#else
#import "YYWebImage.h"
#endif

@implementation KSYYImageManager

- (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL *)imageURL
                 placeholder:(UIImage *)placeholder
                    progress:(KSImageManagerProgressBlock)progress
                  completion:(KSImageManagerCompletionBlock)completion
{
    YYWebImageProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progress) {
            progress(receivedSize, expectedSize);
        }
    };
    YYWebImageCompletionBlock completionBlock = ^(UIImage *image,  NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        if (completion) {
            BOOL success = (stage == YYWebImageStageFinished) && !error;
            completion(image, url, success, error);
        }
    };
    [imageView yy_setImageWithURL:imageURL placeholder:placeholder options:kNilOptions progress:progressBlock transform:nil completion:completionBlock];
}

- (void)cancelImageRequestForImageView:(UIImageView *)imageView {
    [imageView yy_cancelCurrentImageRequest];
}

- (UIImage *)imageFromMemoryForURL:(NSURL *)url {
    YYWebImageManager *manager = [YYWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    return [manager.cache getImageForKey:key withType:YYImageCacheTypeMemory];
}

@end
