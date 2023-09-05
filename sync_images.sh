#!/bin/sh
# Copyright (c) 2022 Institute of Software, Chinese Academy of Sciences (ISCAS)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


FILE=EulixSpace/Define/ESImageDefine.h

echo "// GENERATED CODE - DO NOT MODIFY BY HAND" >$FILE
echo "// @see sync_images.sh" >>$FILE
echo "// #import \"ESImageDefine.h\"" >>$FILE
echo "" >>$FILE
echo "#ifndef ESImageDefine_h" >>$FILE
echo "#define ESImageDefine_h" >>$FILE
echo "" >>$FILE
echo "#import <UIKit/UIKit.h>" >>$FILE
echo "" >>$FILE

listAllImages() {
    cd $1
    for f in *.imageset; do
        if [ "${f##*.}" = "imageset" ]; then
            echo ${f/.imageset/}
            ## IMAGE_<#value#> = [UIImage imageNamed:<#value#>]
            echo \#define IMAGE_$(echo ${f/.imageset/} | tr 'a-z' 'A-Z')" [UIImage imageNamed:@\"${f/.imageset/}\"]" >>../../$FILE
        fi
    done
    cd -
}

listAllImages EulixSpace/Assets.xcassets
echo "" >>$FILE
echo "#endif /* ESImageDefine_h */" >>$FILE
