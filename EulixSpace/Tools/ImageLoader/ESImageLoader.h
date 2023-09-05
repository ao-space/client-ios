/*
 * Copyright (c) 2022 Institute of Software, Chinese Academy of Sciences (ISCAS)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  ESImageLoader.h
//  EulixSpace
//
//  Created by Ye Tao on 2021/9/18.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDImageLoader.h>

@interface ESImageLoader : NSObject <SDImageLoader>

/**
 Whether current image loader supports to load the provide image URL, with associated options and context.
 This will be checked every time a new image request come for loader. If this return NO, we will mark this image load as failed. If return YES, we will start to call `requestImageWithURL:options:context:progress:completed:`.

 @param url The image URL to be loaded.
 @param options A mask to specify options to use for this request
 @param context A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 @return YES to continue download, NO to stop download.
 */
- (BOOL)canRequestImageForURL:(nullable NSURL *)url
                      options:(SDWebImageOptions)options
                      context:(nullable SDWebImageContext *)context;

/**
 Load the image and image data with the given URL and return the image data. You're responsible for producing the image instance.

 @param url The URL represent the image. Note this may not be a HTTP URL
 @param options A mask to specify options to use for this request
 @param context A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 @param progressBlock A block called while image is downloading
 *                    @note the progress block is executed on a background queue
 @param completedBlock A block called when operation has been completed.
 @return An operation which allow the user to cancel the current request.
 */
- (nullable id<SDWebImageOperation>)requestImageWithURL:(nullable NSURL *)url
                                                options:(SDWebImageOptions)options
                                                context:(nullable SDWebImageContext *)context
                                               progress:(nullable SDImageLoaderProgressBlock)progressBlock
                                              completed:(nullable SDImageLoaderCompletedBlock)completedBlock;

/**
 Whether the error from image loader should be marked indeed un-recoverable or not.
 If this return YES, failed URL which does not using `SDWebImageRetryFailed` will be blocked into black list. Else not.

 @param url The URL represent the image. Note this may not be a HTTP URL
 @param error The URL's loading error, from previous `requestImageWithURL:options:context:progress:completed:` completedBlock's error.
 @return Whether to block this url or not. Return YES to mark this URL as failed.
 */
- (BOOL)shouldBlockFailedURLWithURL:(nonnull NSURL *)url
                              error:(nonnull NSError *)error API_DEPRECATED("Use shouldBlockFailedURLWithURL:error:options:context: instead", macos(10.10, API_TO_BE_DEPRECATED), ios(8.0, API_TO_BE_DEPRECATED), tvos(9.0, API_TO_BE_DEPRECATED), watchos(2.0, API_TO_BE_DEPRECATED));

/**
 Whether the error from image loader should be marked indeed un-recoverable or not, with associated options and context.
 If this return YES, failed URL which does not using `SDWebImageRetryFailed` will be blocked into black list. Else not.

 @param url The URL represent the image. Note this may not be a HTTP URL
 @param error The URL's loading error, from previous `requestImageWithURL:options:context:progress:completed:` completedBlock's error.
 @param options A mask to specify options to use for this request
 @param context A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 @return Whether to block this url or not. Return YES to mark this URL as failed.
 */
- (BOOL)shouldBlockFailedURLWithURL:(nonnull NSURL *)url
                              error:(nonnull NSError *)error
                            options:(SDWebImageOptions)options
                            context:(nullable SDWebImageContext *)context;

@end
