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


FILE=EulixSpace/Define/ESLocalizableDefine.h

echo "// GENERATED CODE - DO NOT MODIFY BY HAND" >$FILE
echo "// @see sync_localizable.sh" >>$FILE
echo '// #import "ESLocalizableDefine.h"' >>$FILE
echo "" >>$FILE
echo "#ifndef ESLocalizableDefine_h" >>$FILE
echo "#define ESLocalizableDefine_h" >>$FILE
echo "" >>$FILE
echo "#import <Foundation/Foundation.h>" >>$FILE
echo "" >>$FILE
listAllLocalizable() {
    content=$(cat $1 | grep =)
    OLD_IFS=$IFS
    IFS=";"
    arr=($content)
    for string in "${arr[@]}"; do
        string=$(echo $string | tr -d '[:space:]' | tr -d '""')
        echo $string
        INNER_IFS=$IFS
        IFS="="
        key_value=($string)
        key=${key_value[0]}
        key_upper=$(echo ${key_value[0]} | tr 'a-z' 'A-Z')
        value=${key_value[1]}
        if [ ${#key} -gt 1 ]; then
            echo "// $value" >>./$FILE
            echo "#define TEXT_$key_upper NSLocalizedString(@\"$key\", @\"$value\")" >>./$FILE
        fi
        IFS=$INNER_IFS
    done
    IFS=$OLD_IFS
}
listAllLocalizable ./EulixSpace/Application/zh-Hans.lproj/Localizable.strings
echo "" >>$FILE
echo "#endif /* ESLocalizableDefine_h */" >>$FILE
