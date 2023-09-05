#  绑定盒子流程

## 连接盒子

1. 通过`btid` 生成`eulixspace-xxx` 以及`ServiceUUID`,搜索蓝牙
1. 连接到蓝牙

示例
```
btid = 4887b4bd99a33e8a
localName = eulixspace-4887b4bd99a33e8a
ServiceUUID = 4887B4BD-99A3-3E8A-0000-000000000000
```

## 获取盒子状态

1. [CMD]`PubKeyExchangeReq` 公钥交换请求 app -> box
1. [CMD]`PubKeyExchangeRsp` 公钥交换响应 box -> app
1. [CMD]`KeyExchangeReq` 对称密钥交换请求 app -> box
1. [CMD]`KeyExchangeRsp` 对称密钥交换响应 box -> app
1. [CMD]`InitReq` 初始化请求 app->box
1. [CMD]`InitRsp` 初始化响应 box -> app 获取盒子状态

配对状态

```
0: 已配对和管理员绑定
1: 未绑定、未配对过(新盒子)
2: 管理员已经解绑;
```
## 新盒子

`ESInitResult`的`paired == 1`

1. [Page]跳转页面盒子配网
    1. [CMD]`WifiListReq` Wifi列表请求 app -> box
    1. [CMD]`WifiListRsp` Wifi列表响应 box -> app
    1. [可选]输入 wifi 密码
        1. [CMD]`WifiPwdReq` 连接WIFI请求 app -> box
        1. [CMD]`WifiPwdRsp` 连接WIFI响应 box -> app
    1. [CMD]`PairReq` 配对请求 app -> box
    1. [CMD]`PairRsp` 配对响应 box -> app
1. [Page] 设置安全密码
    1. [CMD]`SetAdminPwdReq` 管理员设置管理密码请求 app -> box
    1. [CMD]`SetAdminPwdRsp` 管理员设置管理密码响应 box -> app
1. [Page] 初始化
    1. [CMD]`InitialReq` 盒子完成初始化请求 app -> box
    1. [CMD]`InitialRsp` 盒子完成初始化响应 box -> app
1. [Page] 绑定结果
    1. [If]成功, 保存盒子信息
    1. [If]失败, 点击返回则返回盒子列表


## 老盒子

`ESInitResult`的`paired == 0`

`ESInitResult`的`paired == 2`

1. [Page] 校验盒子密码, 并且解绑管理员
    1. [CMD]`RevokeReq` 管理员解绑请求 app -> box
    1. [CMD]`RevokeRsp` 管理员解绑响应 box -> app
1. [Page]跳转页面盒子配网
    1. [CMD]`WifiListReq` Wifi列表请求 app -> box
    1. [CMD]`WifiListRsp` Wifi列表响应 box -> app
    1. [可选]输入 wifi 密码
          1. [CMD]`WifiPwdReq` 连接WIFI请求 app -> box
          1. [CMD]`WifiPwdRsp` 连接WIFI响应 box -> app
    1. [CMD]`PairReq` 配对请求 app -> box
    1. [CMD]`PairRsp` 配对响应 box -> app
    1. [CMD]`InitialReq` 盒子完成初始化请求 app -> box
    1. [CMD]`InitialRsp` 盒子完成初始化响应 box -> app
1. [Page] 绑定结果
    1. [If]成功, 保存盒子信息
    1. [If]失败, 点击返回则返回盒子列表


