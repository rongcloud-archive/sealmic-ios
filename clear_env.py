#coding=utf-8

#  clear_env.py
#  SealClass
#
#  Created by Sin on 19/3/28
#  Copyright (c) 2019 RongCloud. All rights reserved.

import io

# usage : python clear_env.py

#去除特定的敏感信息
# file:需要处理的文件
# old_str:包含特定文本的字符串，会查找该字符串存在行，并用新字符串替换一整行
# new_str:要被替换的字符串
def replace(file,old_str,new_str):
    
    file_data = ""

    with io.open(file, "r", encoding="utf-8") as f:
         for line in f:
            if old_str in line:
                line = new_str 
            file_data += line
    with io.open(file,"w",encoding="utf-8") as f:
        f.write(file_data)


replace("./SealMic/AppDelegate.m",'NSString *const APPKey = ',"NSString *const APPKey = @\"Your AppKey\";\n")
replace("./SealMic/AppDelegate.m",'NSString *const BuglyKey = ',"NSString *const BuglyKey = @\"Your BuglyKey\";\n")
replace("./SealMic/Util/HTTP/HTTPUtility.m",'NSString *const BASE_URL = ',"NSString *const BASE_URL = @\"Your Server URL\";\n")