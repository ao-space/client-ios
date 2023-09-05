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
//  ESFileDefineImp.m
//  EulixSpace
//
//  Created by Ye Tao on 2021/5/25.
//  Copyright © 2021 eulix.xyz. All rights reserved.
//

#import "ESBoxManager.h"
#import "ESFileDefine.h"
#import "ESImageDefine.h"
#import "ESLocalPath.h"
#import "ESFileInfoPub.h"
#import "ESMyShareRsp.h"
#import "ESPicModel.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "ESFileInfoPub+ESTool.h"

NSUInteger const kPerByteInKilo = 1024;

extern NSString *FileSizeString(UInt64 length, BOOL showUnit) {
    NSString *unit = @"";
    float size = 0.0;
    if (length >= pow(kPerByteInKilo, 4)) {
        size = (float)(length / (float)pow(kPerByteInKilo, 4));
        unit = @"T";
    } else if (length >= pow(kPerByteInKilo, 3)) {
        size = (float)(length / (float)pow(kPerByteInKilo, 3));
        unit = @"G";
    } else if (length >= pow(kPerByteInKilo, 2)) {
        size = (float)(length / (float)pow(kPerByteInKilo, 2));
        unit = @"M";
    } else if (length >= kPerByteInKilo) {
        size = (float)(length / (float)kPerByteInKilo);
        unit = @"K";
    } else {
        size = (float)(length);
        unit = @"B";
    }
    if (!showUnit) {
        unit = @"";
    }
    return [NSString stringWithFormat:@"%.1f%@", size, unit];
}

extern NSString *FileSizeString1(UInt64 length, BOOL showUnit) {
    NSString *unit = @"";
    float size = 0.0;
    if (length >= pow(kPerByteInKilo, 4)) {
        size = (float)(length / (float)pow(kPerByteInKilo, 4));
        unit = @"T";
    } else if (length >= pow(kPerByteInKilo, 3)) {
        size = (float)(length / (float)pow(kPerByteInKilo, 3));
        unit = @"G";
    } else if (length >= pow(kPerByteInKilo, 2)) {
        size = (float)(length / (float)pow(kPerByteInKilo, 2));
        unit = @"M";
    } else if (length >= kPerByteInKilo) {
        size = (float)(length / (float)kPerByteInKilo);
        unit = @"K";
    } else {
        size = (float)(length);
        unit = @"B";
    }
    if (!showUnit) {
        unit = @"";
    }
    return [NSString stringWithFormat:@"%d%@", (int)size, unit];
}


extern NSString * CapacitySizeString(UInt64 length, UInt64 base, BOOL showUnit) {
    NSString *unit = @"";
    float size = 0.0;
    if (length >= pow(base, 4)) {
        size = (float)(length / (float)pow(base, 4));
        unit = @"T";
    } else if (length >= pow(base, 3)) {
        size = (float)(length / (float)pow(base, 3));
        unit = @"G";
    } else if (length >= pow(base, 2)) {
        size = (float)(length / (float)pow(base, 2));
        unit = @"M";
    } else if (length >= base) {
        size = (float)(length / (float)base);
        unit = @"K";
    } else {
        size = (float)(length);
        unit = @"B";
    }
    if (!showUnit) {
        unit = @"";
    }
    return [NSString stringWithFormat:@"%.1f%@", size, unit];
}

extern NSString * es_NetworkSpeedString(CGFloat value) {
    int base = 1024;
    NSString *unit = @"B/s";
    float size = value;
    if (value >= pow(base, 4)) {
        size = value / pow(base, 4);
        unit = @"TB/s";
    } else if (value >= pow(base, 3)) {
        size = value / pow(base, 3);
        unit = @"GB/s";
    } else if (value >= pow(base, 2)) {
        size = value / pow(base, 2);
        unit = @"MB/s";
    } else if (value >= base) {
        size = value / base;
        unit = @"KB/s";
    }

    return [NSString stringWithFormat:@"%.1f %@", size, unit];
}

extern NSString *MediaType(NSString *ext) {
    static NSDictionary *_map = nil;
    if (!_map) {
        _map = @{
            @"3ds": @"image/x-3ds",
            @"apng": @"image/apng",
            @"arw": @"image/x-sony-arw",
            @"azv": @"image/vnd.airzip.accelerator.azv",
            @"bmp": @"image/x-ms-bmp",
            @"btif": @"image/prs.btif",
            @"cgm": @"image/cgm",
            @"cmx": @"image/x-cmx",
            @"cr2": @"image/x-canon-cr2",
            @"crw": @"image/x-canon-crw",
            @"djv": @"image/vnd.djvu",
            @"djvu": @"image/vnd.djvu",
            @"dng": @"image/x-adobe-dng",
            @"drle": @"image/dicom-rle",
            @"dwg": @"image/vnd.dwg",
            @"dxf": @"image/vnd.dxf",
            @"emf": @"image/emf",
            @"erf": @"image/x-epson-erf",
            @"exr": @"image/aces",
            @"fbs": @"image/vnd.fastbidsheet",
            @"fh": @"image/x-freehand",
            @"fh4": @"image/x-freehand",
            @"fh5": @"image/x-freehand",
            @"fh7": @"image/x-freehand",
            @"fhc": @"image/x-freehand",
            @"fits": @"image/fits",
            @"fpx": @"image/vnd.fpx",
            @"fst": @"image/vnd.fst",
            @"g3": @"image/g3fax",
            @"gif": @"image/gif",
            @"heic": @"image/heic",
            @"heics": @"image/heic-sequence",
            @"heif": @"image/heif",
            @"heifs": @"image/heif-sequence",
            @"ico": @"image/x-icon",
            @"ief": @"image/ief",
            @"jls": @"image/jls",
            @"jng": @"image/x-jng",
            @"jp2": @"image/jp2",
            @"jpe": @"image/jpeg",
            @"jpeg": @"image/jpeg",
            @"jpf": @"image/jpx",
            @"jpg": @"image/jpeg",
            @"jpg2": @"image/jp2",
            @"jpx": @"image/jpx",
            @"k25": @"image/x-kodak-k25",
            @"kdc": @"image/x-kodak-kdc",
            @"ktx": @"image/ktx",
            @"mdi": @"image/vnd.ms-modi",
            @"mmr": @"image/vnd.fujixerox.edmics-mmr",
            @"mrw": @"image/x-minolta-mrw",
            @"nef": @"image/x-nikon-nef",
            @"npx": @"image/vnd.net-fpx",
            @"orf": @"image/x-olympus-orf",
            @"pbm": @"image/x-portable-bitmap",
            @"pct": @"image/x-pict",
            @"pcx": @"image/x-pcx",
            @"pef": @"image/x-pentax-pef",
            @"pgm": @"image/x-portable-graymap",
            @"pic": @"image/x-pict",
            @"png": @"image/png",
            @"pnm": @"image/x-portable-anymap",
            @"ppm": @"image/x-portable-pixmap",
            @"psd": @"image/vnd.adobe.photoshop",
            @"pti": @"image/prs.pti",
            @"raf": @"image/x-fuji-raf",
            @"ras": @"image/x-cmu-raster",
            @"raw": @"image/x-panasonic-raw",
            @"rgb": @"image/x-rgb",
            @"rlc": @"image/vnd.fujixerox.edmics-rlc",
            @"sgi": @"image/sgi",
            @"sid": @"image/x-mrsid-image",
            @"sr2": @"image/x-sony-sr2",
            @"srf": @"image/x-sony-srf",
            @"svg": @"image/svg+xml",
            @"svgz": @"image/svg+xml",
            @"t38": @"image/t38",
            @"tap": @"image/vnd.tencent.tap",
            @"tfx": @"image/tiff-fx",
            @"tga": @"image/x-tga",
            @"tif": @"image/tiff",
            @"tiff": @"image/tiff",
            @"uvg": @"image/vnd.dece.graphic",
            @"uvi": @"image/vnd.dece.graphic",
            @"uvvg": @"image/vnd.dece.graphic",
            @"uvvi": @"image/vnd.dece.graphic",
            @"vtf": @"image/vnd.valve.source.texture",
            @"wbmp": @"image/vnd.wap.wbmp",
            @"wdp": @"image/vnd.ms-photo",
            @"webp": @"image/webp",
            @"wmf": @"image/wmf",
            @"x3f": @"image/x-sigma-x3f",
            @"xbm": @"image/x-xbitmap",
            @"xif": @"image/vnd.xiff",
            @"xpm": @"image/x-xpixmap",
            @"xwd": @"image/x-xwindowdump",
            @"3g2": @"video/3gpp2",
            @"3gp": @"video/3gpp",
            @"3gpp": @"video/3gpp",
            @"asf": @"video/x-ms-asf",
            @"asx": @"video/x-ms-asf",
            @"avi": @"video/x-msvideo",
            @"dvb": @"video/vnd.dvb.file",
            @"f4v": @"video/x-f4v",
            @"fli": @"video/x-fli",
            @"flv": @"video/x-flv",
            @"fvt": @"video/vnd.fvt",
            @"h261": @"video/h261",
            @"h263": @"video/h263",
            @"h264": @"video/h264",
            @"jpgm": @"video/jpm",
            @"jpgv": @"video/jpeg",
            @"jpm": @"video/jpm",
            @"m1v": @"video/mpeg",
            @"m2v": @"video/mpeg",
            @"m4u": @"video/vnd.mpegurl",
            @"m4v": @"video/x-m4v",
            @"mj2": @"video/mj2",
            @"mjp2": @"video/mj2",
            @"mk3d": @"video/x-matroska",
            @"mks": @"video/x-matroska",
            @"mkv": @"video/x-matroska",
            @"mng": @"video/x-mng",
            @"mov": @"video/quicktime",
            @"movie": @"video/x-sgi-movie",
            @"mp4": @"video/mp4",
            @"mp4v": @"video/mp4",
            @"mpe": @"video/mpeg",
            @"mpeg": @"video/mpeg",
            @"mpg": @"video/mpeg",
            @"mpg4": @"video/mp4",
            @"mxu": @"video/vnd.mpegurl",
            @"ogv": @"video/ogg",
            @"pyv": @"video/vnd.ms-playready.media.pyv",
            @"qt": @"video/quicktime",
            @"smv": @"video/x-smv",
            @"ts": @"video/mp2t",
            @"uvh": @"video/vnd.dece.hd",
            @"uvm": @"video/vnd.dece.mobile",
            @"uvp": @"video/vnd.dece.pd",
            @"uvs": @"video/vnd.dece.sd",
            @"uvu": @"video/vnd.uvvu.mp4",
            @"uvv": @"video/vnd.dece.video",
            @"uvvh": @"video/vnd.dece.hd",
            @"uvvm": @"video/vnd.dece.mobile",
            @"uvvp": @"video/vnd.dece.pd",
            @"uvvs": @"video/vnd.dece.sd",
            @"uvvu": @"video/vnd.uvvu.mp4",
            @"uvvv": @"video/vnd.dece.video",
            @"viv": @"video/vnd.vivo",
            @"vob": @"video/x-ms-vob",
            @"webm": @"video/webm",
            @"wm": @"video/x-ms-wm",
            @"wmv": @"video/x-ms-wmv",
            @"wmx": @"video/x-ms-wmx",
            @"wvx": @"video/x-ms-wvx",
        };
    }
    return [_map[ext] componentsSeparatedByString:@"/"].firstObject;
}

extern UIImage *IconForShareFile(id fileOrFileName) {
    NSString *fileName = fileOrFileName;
    if ([fileOrFileName isKindOfClass:[ESMyShareRsp class]]) {
//        if (IsImageForFile(fileOrFileName)) {
//            return IMAGE_FILE_TYPE_IMAGE;
//        }
//        if (IsVideoForFile(fileOrFileName)) {
//            return IMAGE_FILE_TYPE_VIDEO;
//        }
        fileName = ((ESMyShareRsp *)fileOrFileName).fileName;
    }

    NSString *ext = [fileName componentsSeparatedByString:@"."].lastObject.lowercaseString;
    static NSDictionary *_map = nil;
    if (!_map) {
        _map = @{
            @"pdf": IMAGE_FILE_TYPE_PDF,

            ///
            @"psd": IMAGE_FILE_TYPE_PSD,
            @"ai": IMAGE_FILE_TYPE_AI,

            //rar
            @"zip": IMAGE_FILE_TYPE_RAR,
            @"rar": IMAGE_FILE_TYPE_RAR,
            @"7z": IMAGE_FILE_TYPE_RAR,
            @"tar": IMAGE_FILE_TYPE_RAR,
            @"jar": IMAGE_FILE_TYPE_RAR,
            @"iso": IMAGE_FILE_TYPE_RAR,
            @"gz": IMAGE_FILE_TYPE_RAR,

            //office
            @"doc": IMAGE_FILE_TYPE_WORD,
            @"docx": IMAGE_FILE_TYPE_WORD,
            @"xls": IMAGE_FILE_TYPE_EXCEL,
            @"xlsx": IMAGE_FILE_TYPE_EXCEL,
            @"ppt": IMAGE_FILE_TYPE_PPT,
            @"pptx": IMAGE_FILE_TYPE_PPT,

            //
            @"txt": IMAGE_FILE_TYPE_TEXT,
            @"md": IMAGE_FILE_TYPE_TEXT,
            @"html": IMAGE_FILE_TYPE_HTML,

            //
            @"mp3": IMAGE_FILE_TYPE_AUDIO,

            //
            @"bt": IMAGE_FILE_TYPE_TORRENT,
        };
    }

    if (!ext) {
        return IMAGE_FILE_TYPE_WEIZHI;
    }
    NSString *mediaType = MediaType(ext);
    if ([mediaType isEqualToString:@"video"]) {
        return IMAGE_FILE_TYPE_VIDEO;
    }
    if ([mediaType isEqualToString:@"image"]) {
        return IMAGE_FILE_TYPE_IMAGE;
    }
    return _map[ext] ?: IMAGE_FILE_TYPE_WEIZHI;
}

extern UIImage *IconForFile(id fileOrFileName) {
    NSString *fileName = fileOrFileName;
    if ([fileOrFileName isKindOfClass:[ESFileInfoPub class]]) {
        if (IsImageForFile(fileOrFileName)) {
            return IMAGE_FILE_TYPE_IMAGE;
        }
        if (IsVideoForFile(fileOrFileName)) {
            return IMAGE_FILE_TYPE_VIDEO;
        }
        fileName = ((ESFileInfoPub *)fileOrFileName).name;
    }

    NSString *ext = [fileName componentsSeparatedByString:@"."].lastObject.lowercaseString;
    static NSDictionary *_map = nil;
    if (!_map) {
        _map = @{
            @"pdf": IMAGE_FILE_TYPE_PDF,

            ///
            @"psd": IMAGE_FILE_TYPE_PSD,
            @"ai": IMAGE_FILE_TYPE_AI,

            //rar
            @"zip": IMAGE_FILE_TYPE_RAR,
            @"rar": IMAGE_FILE_TYPE_RAR,
            @"7z": IMAGE_FILE_TYPE_RAR,
            @"tar": IMAGE_FILE_TYPE_RAR,
            @"jar": IMAGE_FILE_TYPE_RAR,
            @"iso": IMAGE_FILE_TYPE_RAR,
            @"gz": IMAGE_FILE_TYPE_RAR,

            //office
            @"doc": IMAGE_FILE_TYPE_WORD,
            @"docx": IMAGE_FILE_TYPE_WORD,
            @"xls": IMAGE_FILE_TYPE_EXCEL,
            @"xlsx": IMAGE_FILE_TYPE_EXCEL,
            @"ppt": IMAGE_FILE_TYPE_PPT,
            @"pptx": IMAGE_FILE_TYPE_PPT,

            //
            @"txt": IMAGE_FILE_TYPE_TEXT,
            @"md": IMAGE_FILE_TYPE_TEXT,
            @"html": IMAGE_FILE_TYPE_HTML,

            //
            @"mp3": IMAGE_FILE_TYPE_AUDIO,

            //
            @"bt": IMAGE_FILE_TYPE_TORRENT,
        };
    }

    if (!ext) {
        return IMAGE_FILE_TYPE_WEIZHI;
    }
    NSString *mediaType = MediaType(ext);
    if ([mediaType isEqualToString:@"video"]) {
        return IMAGE_FILE_TYPE_VIDEO;
    }
    if ([mediaType isEqualToString:@"image"]) {
        return IMAGE_FILE_TYPE_IMAGE;
    }
    return _map[ext] ?: IMAGE_FILE_TYPE_WEIZHI;
}

extern BOOL IsImageForFile(ESFileInfoPub *file) {
    return [file.category isEqualToString:@"picture"];
}

extern BOOL IsVideoForFile(ESFileInfoPub *file) {
    return [file.category isEqualToString:@"video"];
}

extern BOOL IsMediaForFile(ESFileInfoPub *file) {
    return IsImageForFile(file) || IsVideoForFile(file);
}

extern NSString *LocalPathForFile(ESFileInfoPub *file) {
    NSString *localPath = [NSString cacheLocationWithDir:file.uuid];
    return [NSString stringWithFormat:@"%@%@", localPath, file.name.URLEncode];
}

extern BOOL LocalFileExist(ESFileInfoPub *file) {
    return [file hasLocalOriginalFile];
}


extern NSString *CompressedPathForFile(ESFileInfoPub *file) {
    NSString *dir = [NSString stringWithFormat:@"hd/%@", file.uuid];
    if (file && file.name) {
        return [[NSString cacheLocationWithDir:dir] stringByAppendingString:file.name.URLEncode];
    } else {
        return @"";
    }
}

extern BOOL CompressedImageExist(ESFileInfoPub *file) {
    NSString *path = CompressedPathForFile(file);
    NSDictionary *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:path.fullCachePath error:nil];
    //后台返回很小的40byte文件，非正常原文件
    if (attrs != nil && [attrs[NSFileSize] unsignedLongLongValue] > 100) {
        return YES;
    }
    return NO;
}

extern NSString *ThumbnailPathForFileUUIDAndName(NSString *uuid, NSString *name) {
    NSString *dir = [NSString stringWithFormat:@"thumbnail/%@", uuid];
    return [[NSString cacheLocationWithDir:dir] stringByAppendingString:name.URLEncode];
}

extern NSString *ThumbnailPathForFile(ESFileInfoPub *file) {
    return ThumbnailPathForFileUUIDAndName(file.uuid, file.name);
}

extern BOOL ThumbnailImageExist(ESFileInfoPub *file) {
    NSString *path = ThumbnailPathForFile(file);
    NSDictionary *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:path.fullCachePath error:nil];
    if (!attrs) {
        return NO;
    }
    return YES;
}

extern NSString *ContentTypeForPathExtension(NSString *extension) {
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    return contentType ?: @"application/octet-stream";
}

extern NSString *ThumbnailUrlForFile(ESFileInfoPub *file, CGSize size) {
    //现在是固定分辨率的缩略图
    size = CGSizeMake(360, 360);
    NSString *domain = ESBoxManager.activeBox.prettyDomain;
    if (ESBoxManager.activeBox.enableInternetAccess == NO  && ESBoxManager.activeBox.localHost.length > 0) {
        domain = ESBoxManager.activeBox.localHost;
    }
    return [NSString stringWithFormat:@"%@/thumb/%@?size=%.fx%.f&name=%@", domain, file.uuid, size.width, size.height, file.name.URLEncode];
}

///https://code.eulix.xyz/bp/portal/-/blob/main/product%E4%BA%A7%E5%93%81/%E5%8A%9F%E8%83%BD%E8%AE%BE%E8%AE%A1/storage%E5%AD%98%E5%82%A8/definition%E5%AE%9A%E4%B9%89/%E6%94%AF%E6%8C%81%E9%A2%84%E8%A7%88%E7%9A%84%E6%96%87%E4%BB%B6%E6%A0%BC%E5%BC%8F.md
extern BOOL UnsupportFileForPreview(ESFileInfoPub *file) {
    NSString *ext = [file.name componentsSeparatedByString:@"."].lastObject.lowercaseString;
    NSSet *_supportSet = nil;
    if (!_supportSet) {
        _supportSet = [NSSet setWithArray:@[
            ///0.7.0_图片
            @"jpg",
            @"jpeg",
            @"png",
            @"bmp",
            @"gif",
            @"webp",
            @"heic",
            ///0.7.0_视频
            @"mp4",
            //@"avi",  ios 默认不支持
           // @"mkv",  ios 不支持
            //@"3gp",  ios 默认不支持
            @"mov",
            ///0.7.0_文档
            @"txt",
            @"pdf",
            @"doc",
            @"docx",
            @"xls",
            @"xlsx",
            @"ppt",
            @"pptx",
        ]];
    }
    return ext.length == 0 || ![_supportSet containsObject:ext];
}

extern BOOL UnsupportFilePhotoForPreview(ESPicModel *pic) {
    NSString *ext = [pic.name componentsSeparatedByString:@"."].lastObject.lowercaseString;
    NSSet *_supportSet = nil;
    if (!_supportSet) {
        _supportSet = [NSSet setWithArray:@[
            ///0.7.0_图片
            @"jpg",
            @"jpeg",
            @"png",
            @"bmp",
            @"gif",
            @"webp",
            @"heic",
            ///0.7.0_视频
            @"mp4",
            //@"avi",  ios 默认不支持
            //@"mkv",   ios 不支持
            //@"3gp",  ios 默认不支持
            @"mov",
            ///0.7.0_文档
            @"txt",
            @"pdf",
            @"doc",
            @"docx",
            @"xls",
            @"xlsx",
            @"ppt",
            @"pptx",
        ]];
    }
    return ext.length == 0 || ![_supportSet containsObject:ext];
}
