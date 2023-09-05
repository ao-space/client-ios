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
//  WMPlayerModel.h
//  
//
//  Created by zhengwenming on 2018/4/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface WMPlayerModel : NSObject
//视频标题
@property (nonatomic, copy) NSString   *title;
//视频的URL，本地路径or网络路径http
@property (nonatomic, strong) NSURL    *videoURL;
//videoURL和playerItem二选一
@property (nonatomic, strong) AVPlayerItem   *playerItem;
//跳到seekTime处播放
@property (nonatomic, assign) double   seekTime;
@property (nonatomic, strong) NSIndexPath  *indexPath;
//视频尺寸
@property (nonatomic,assign) CGSize presentationSize;
//是否是适合竖屏播放的资源，w：h<1的资源，一般是手机竖屏（人像模式）拍摄的视频资源
@property (nonatomic,assign) BOOL verticalVideo;

@end
