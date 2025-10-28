import 'package:bili_plus/http/constants.dart';

class Api {
  // 推荐视频
  static const String recommendListApp =
      '${HttpString.appBaseUrl}/x/v2/feed/index';
  static const String recommendListWeb = '/x/web-interface/index/top/feed/rcmd';

  // APP端不感兴趣、取消不感兴趣
  static const String feedDislike = '${HttpString.appBaseUrl}/x/feed/dislike';
  static const String feedDislikeCancel =
      '${HttpString.appBaseUrl}/x/feed/dislike/cancel';

  // 热门视频
  static const String hotList = '/x/web-interface/popular';

  // 视频流
  // https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/video/videostream_url.md
  static const String ugcUrl = '/x/player/wbi/playurl';

  // 番剧视频流
  // https://api.bilibili.com/pgc/player/web/v2/playurl?cid=104236640&bvid=BV13t411n7ex
  static const String pgcUrl = '/pgc/player/web/v2/playurl';

  static const String pugvUrl = '/pugv/player/web/playurl';

  // 字幕
  // aid, cid
  static const String playInfo = '/x/player/wbi/v2';

  // 视频详情
  // 竖屏 https://api.bilibili.com/x/web-interface/view?aid=527403921
  // https://api.bilibili.com/x/web-interface/view/detail  获取视频超详细信息(web端)
  static const String videoIntro = '/x/web-interface/view';
  // 视频详情 超详细
  // https://api.bilibili.com/x/web-interface/view/detail?aid=527403921

  /// https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/video/action.md
  // 点赞 Post
  /// aid	num	稿件avid	必要（可选）	avid与bvid任选一个
  /// bvid	str	稿件bvid	必要（可选）	avid与bvid任选一个
  /// like	num	操作方式	必要	1：点赞 2：取消赞
  // csrf	str	CSRF Token（位于cookie）	必要
  // https://api.bilibili.com/x/web-interface/archive/like
  // static const String likeVideo = '/x/web-interface/archive/like';

  // 改用app端点赞接口
  static const String likeVideo = '${HttpString.appBaseUrl}/x/v2/view/like';
  //判断视频是否被点赞（双端）Get
  // access_key	str	APP登录Token	APP方式必要
  /// aid	num	稿件avid	必要（可选）	avid与bvid任选一个
  /// bvid	str	稿件bvid	必要（可选）	avid与bvid任选一个
  // https://api.bilibili.com/x/web-interface/archive/has/like
  // static const String hasLikeVideo = '/x/web-interface/archive/has/like';

  static const String pgcLikeCoinFav = '/pgc/season/episode/community';

  // 视频点踩 web端不支持

  // 点踩 Post(app端)
  /// access_key str	APP登录Token 必要
  /// aid num	稿件avid	必要
  ///
  static const String dislikeVideo =
      '${HttpString.appBaseUrl}/x/v2/view/dislike';

  // 投币视频（web端）POST
  /// aid	num	稿件avid	必要（可选）	avid与bvid任选一个
  /// bvid	str	稿件bvid	必要（可选）	avid与bvid任选一个
  /// multiply	num	投币数量	必要	上限为2
  /// select_like	num	是否附加点赞	非必要	0：不点赞 1：同时点赞 默认为0
  // csrf	str	CSRF Token（位于cookie）	必要
  // https://api.bilibili.com/x/web-interface/coin/add
  // static const String coinVideo = '/x/web-interface/coin/add';

  // 改用app端投币接口
  static const String coinVideo = '${HttpString.appBaseUrl}/x/v2/view/coin/add';

  // 判断视频是否被投币（双端）GET
  // access_key	str	APP登录Token	APP方式必要
  /// aid	num	稿件avid	必要（可选）	avid与bvid任选一个
  /// bvid	str	稿件bvid	必要（可选）	avid与bvid任选一个
  /// https://api.bilibili.com/x/web-interface/archive/coins
  // static const String hasCoinVideo = '/x/web-interface/archive/coins';

  /// 收藏夹 详情
  /// media_id  当前收藏夹id 搜索全部时为默认收藏夹id
  /// pn int 当前页
  /// ps int pageSize
  /// keyword String 搜索词
  /// order String 排序方式 view 最多播放 mtime 最近收藏 pubtime 最近投稿
  /// tid int 分区id
  /// platform web
  /// type 0 当前收藏夹 1 全部收藏夹
  // https://api.bilibili.com/x/v3/fav/resource/list?media_id=76614671&pn=1&ps=20&keyword=&order=mtime&type=0&tid=0
  static const String favResourceList = '/x/v3/fav/resource/list';

  // 收藏视频（双端）POST
  // access_key	str	APP登录Token	APP方式必要
  /// rid	num	稿件avid	必要
  /// type	num	必须为2	必要
  /// add_media_ids	nums	需要加入的收藏夹mlid	非必要	同时添加多个，用,（%2C）分隔
  /// del_media_ids	nums	需要取消的收藏夹mlid	非必要	同时取消多个，用,（%2C）分隔
  // csrf	str	CSRF Token（位于cookie）	Cookie方式必要
  // https://api.bilibili.com/medialist/gateway/coll/resource/deal
  // https://api.bilibili.com/x/v3/fav/resource/deal
  static const String favVideo = '/x/v3/fav/resource/batch-deal';

  static const String unfavAll = '/x/v3/fav/resource/unfav-all';

  static const String copyFav = '/x/v3/fav/resource/copy';

  static const String moveFav = '/x/v3/fav/resource/move';

  static const String cleanFav = '/x/v3/fav/resource/clean';

  static const String sortFav = '/x/v3/fav/resource/sort';

  static const String sortFavFolder = '/x/v3/fav/folder/sort';

  // 判断视频是否被收藏（双端）GET
  /// aid
  // https://api.bilibili.com/x/v2/fav/video/favoured
  // static const String hasFavVideo = '/x/v2/fav/video/favoured';

  // 分享视频 （Web端） POST
  // https://api.bilibili.com/x/web-interface/share/add
  // aid	num	稿件avid	必要（可选）	avid与bvid任选一个
  // bvid	str	稿件bvid	必要（可选）	avid与bvid任选一个
  // csrf	str	CSRF Token（位于cookie）	必要

  // 一键三连
  // https://api.bilibili.com/x/web-interface/archive/like/triple
  // aid	num	稿件avid	必要（可选）	avid与bvid任选一个
  // bvid	str	稿件bvid	必要（可选）	avid与bvid任选一个
  // csrf	str	CSRF Token（位于cookie）	必要
  static const String ugcTriple = '/x/web-interface/archive/like/triple';

  static const String pgcTriple = '/pgc/season/episode/like/triple';

  // 获取指定用户创建的所有收藏夹信息
  // 该接口也能查询目标内容id存在于那些收藏夹中
  // up_mid	num	目标用户mid	必要
  // type	num	目标内容属性	非必要	默认为全部 0：全部 2：视频稿件
  // rid	num	目标 视频稿件avid
  static const String favFolder = '/x/v3/fav/folder/created/list-all';

  static const String copyToview = '/x/v2/history/toview/copy';

  static const String moveToview = '/x/v2/history/toview/move';

  // 视频详情页 相关视频
  static const String relatedList = '/x/web-interface/archive/related';

  // 查询用户与自己关系_仅查关注
  static const String relation = '/x/relation';

  static const String relations = '/x/relation/relations';

  // 操作用户关系
  static const String relationMod = '/x/relation/modify';

  // 相互关系查询 // 失效
  // static const String relationSearch = '/x/space/wbi/acc/relation';

  // 评论列表
  // https://api.bilibili.com/x/v2/reply/main?csrf=6e22efc1a47225ea25f901f922b5cfdd&mode=3&oid=254175381&pagination_str=%7B%22offset%22:%22%22%7D&plat=1&seek_rpid=0&type=11
  static const String replyList = '/x/v2/reply';

  // 楼中楼
  static const String replyReplyList = '/x/v2/reply/reply';

  // 评论点赞
  static const String likeReply = '/x/v2/reply/action';

  static const String hateReply = '/x/v2/reply/hate';

  // 发表评论
  // https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/comment/action.md
  static const String replyAdd = '/x/v2/reply/add';

  // 删除评论
  // https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/comment/action.md
  static const String replyDel = '/x/v2/reply/del';

  // 用户(被)关注数、投稿数
  // https://api.bilibili.com/x/relation/stat?vmid=697166795
  static const String userStat = '/x/relation/stat';

  // 获取我的表情列表
  // business:reply（回复）dynamic（动态）
  //https://api.bilibili.com/x/emote/user/panel/web?business=reply
  static const String myEmote = '/x/emote/user/panel/web';

  // 获取用户信息
  static const String userInfo = '/x/web-interface/nav';

  // 获取当前用户状态
  static const String userStatOwner = '/x/web-interface/nav/stat';

  // 收藏夹
  // https://api.bilibili.com/x/v3/fav/folder/created/list?pn=1&ps=10&up_mid=17340771
  static const String userFavFolder = '/x/v3/fav/folder/created/list';

  static const String favFolderInfo = '/x/v3/fav/folder/info';

  static const String addFolder = '/x/v3/fav/folder/add';

  static const String editFolder = '/x/v3/fav/folder/edit';

  static const String deleteFolder = '/x/v3/fav/folder/del';

  // 正在直播的up & 关注的up
  // https://api.bilibili.com/x/polymer/web-dynamic/v1/portal
  static const String followUp = '/x/polymer/web-dynamic/v1/portal';

  static const String dynUplist = '/x/polymer/web-dynamic/v1/uplist';

  // 关注的up动态
  // https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all
  // https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all?timezone_offset=-480&type=video&page=1&features=itemOpusStyle
  // https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all?host_mid=548196587&offset=&page=1&features=itemOpusStyle
  static const String followDynamic = '/x/polymer/web-dynamic/v1/feed/all';

  // 动态点赞
  // static const String likeDynamic =
  //     '${HttpString.tUrl}/dynamic_like/v1/dynamic_like/thumb';

  // 动态点赞 new
  static const String thumbDynamic = '/x/dynamic/feed/dyn/thumb';

  // 获取稍后再看
  static const String seeYouLater = '/x/v2/history/toview/web';

  // 获取历史记录
  static const String historyList = '/x/web-interface/history/cursor';

  // 暂停历史记录
  static const String pauseHistory = '/x/v2/history/shadow/set';

  // 查询历史记录暂停状态
  static const String historyStatus = '/x/v2/history/shadow?jsonp=jsonp';

  // 清空历史记录
  static const String clearHistory = '/x/v2/history/clear';

  // 删除某条历史记录
  static const String delHistory = '/x/v2/history/delete';

  // 搜索历史记录
  static const String searchHistory = '/x/web-interface/history/search';

  // 热搜
  static const String hotSearchList =
      'https://s.search.bilibili.com/main/hotword';

  // 默认搜索词
  static const String searchDefault = '/x/web-interface/wbi/search/default';

  // 搜索关键词
  static const String searchSuggest =
      'https://s.search.bilibili.com/main/suggest';

  // 分类搜索
  static const String searchByType = '/x/web-interface/wbi/search/type';

  static const String searchAll = '/x/web-interface/wbi/search/all/v2';

  // 记录视频播放进度
  // https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/video/report.md
  static const String heartBeat = '/x/click-interface/web/heartbeat';

  static const String historyReport = '/x/v2/history/report';

  static const String roomEntryAction =
      '${HttpString.liveBaseUrl}/xlive/web-room/v1/index/roomEntryAction';

  static const String mediaListHistory = '/x/v1/medialist/history';

  // 查询视频分P列表 (avid/bvid转cid)
  static const String ab2c = '/x/player/pagelist';

  // 番剧/剧集明细
  static const String pgcInfo = '/pgc/view/web/season';

  static const String pugvInfo = '/pugv/view/web/season';

  // https://api.bilibili.com/pgc/season/episode/web/info?ep_id=12345678
  static const String episodeInfo = '/pgc/season/episode/web/info';

  // 全部关注的up
  // vmid 用户id pn 页码 ps 每页个数，最大50 order: desc
  // order_type 排序规则 最近访问传空，最常访问传 attention
  static const String followings = '/x/relation/followings';

  // 搜索follow
  static const followSearch = '/x/relation/followings/search';

  // 粉丝
  // vmid 用户id pn 页码 ps 每页个数，最大50 order: desc
  // order_type 排序规则 最近访问传空，最常访问传 attention
  static const String fans = '/x/relation/fans';

  // 直播
  // ?page=1&page_size=30&platform=web
  static const String liveList =
      '${HttpString.liveBaseUrl}/xlive/web-interface/v1/second/getUserRecommend';

  // 直播间详情
  // cid roomId
  // qn 80:流畅，150:高清，400:蓝光，10000:原画，20000:4K, 30000:杜比
  static const String liveRoomInfo =
      '${HttpString.liveBaseUrl}/xlive/web-room/v2/index/getRoomPlayInfo';

  static const String sendLiveMsg = '${HttpString.liveBaseUrl}/msg/send';

  // 直播间详情 H5
  static const String liveRoomInfoH5 =
      '${HttpString.liveBaseUrl}/xlive/web-room/v1/index/getH5InfoByRoom';

  // 直播间弹幕预获取
  // roomid roomId
  static const String liveRoomDmPrefetch =
      '${HttpString.liveBaseUrl}/xlive/web-room/v1/dM/gethistory';

  //直播间弹幕密钥获取接口
  static const String liveRoomDmToken =
      '${HttpString.liveBaseUrl}/xlive/web-room/v1/index/getDanmuInfo';

  // 用户信息 需要Wbi签名
  // https://api.bilibili.com/x/space/wbi/acc/info?mid=503427686&token=&platform=web&web_location=1550101&w_rid=d709892496ce93e3d94d6d37c95bde91&wts=1689301482
  static const String memberInfo = '/x/space/wbi/acc/info';

  static const String space = '${HttpString.appBaseUrl}/x/v2/space';

  static const String spaceArchive =
      '${HttpString.appBaseUrl}/x/v2/space/archive/cursor';

  static const String spaceStory =
      '${HttpString.appBaseUrl}/x/v2/feed/index/space/story/cursor';

  static const String spaceChargingArchive =
      '${HttpString.appBaseUrl}/x/v2/space/archive/charging';

  static const String spaceSeason =
      '${HttpString.appBaseUrl}/x/v2/space/season/videos';

  static const String spaceSeries =
      '${HttpString.appBaseUrl}/x/v2/space/series';

  static const String spaceBangumi =
      '${HttpString.appBaseUrl}/x/v2/space/bangumi';

  static const String spaceArticle =
      '${HttpString.appBaseUrl}/x/v2/space/article';

  static const String spaceFav = '/x/v3/fav/folder/space';

  static const String seasonSeries = '/x/polymer/web-space/seasons_series_list';

  // 用户名片信息
  static const String memberCardInfo = '/x/web-interface/card';

  // 用户投稿
  // https://api.bilibili.com/x/space/wbi/arc/search?
  // mid=85754245&
  // ps=30&
  // tid=0&
  // pn=1&
  // keyword=&
  // order=pubdate&
  // platform=web&
  // web_location=1550101&
  // order_avoided=true&
  // w_rid=d893cf98a4e010cf326373194a648360&
  // wts=1689767832
  static const String searchArchive = '/x/space/wbi/arc/search';

  // 用户动态搜索
  // static const String memberDynamicSearch = '/x/space/dynamic/search';
  static const String dynSearch = '/x/polymer/web-dynamic/v1/feed/space/search';

  // 用户动态
  static const String memberDynamic = '/x/polymer/web-dynamic/v1/feed/space';

  // 稍后再看
  static const String toViewLater = '/x/v2/history/toview/add';

  // 移除已观看
  static const String toViewDel = '/x/v2/history/toview/v2/dels';

  // 清空稍后再看
  static const String toViewClear = '/x/v2/history/toview/clear';

  // 追番
  static const String pgcAdd = '/pgc/web/follow/add';

  // 取消追番
  static const String pgcDel = '/pgc/web/follow/del';

  static const String pgcUpdate = '/pgc/web/follow/status/update';

  // 我的追番/追剧 ?type=1&pn=1&ps=15
  static const String favPgc = '/x/space/bangumi/follow/list';

  // 黑名单
  static const String blackLst = '/x/relation/blacks';

  // github 获取最新版
  static const String latestApp =
      'https://api.github.com/repos/bggRGjQaUbCoE/PiliPlus/releases';

  // 多少人在看
  // https://api.bilibili.com/x/player/online/total?aid=913663681&cid=1203559746&bvid=BV1MM4y1s7NZ&ts=56427838
  static const String onlineTotal = '/x/player/online/total';

  // static const String webDanmaku = '/x/v2/dm/web/seg.so';

  // 发送视频弹幕
  //https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/danmaku/action.md
  static const String shootDanmaku = '/x/v2/dm/post';

  // 弹幕屏蔽查询（Get）
  static const String danmakuFilter = '/x/dm/filter/user';

  // 弹幕屏蔽词添加（Post）
  // 表单内容：
  // type: 0（关键词）1（正则）2（用户）
  // filter: 屏蔽内容
  // csrf
  static const String danmakuFilterAdd = '/x/dm/filter/user/add';

  // 弹幕屏蔽词删除（Post）
  // 表单内容：
  // ids: 被删除条目编号
  // csrf
  static const String danmakuFilterDel = '/x/dm/filter/user/del';

  // up主分组
  static const String followUpTag = '/x/relation/tags';

  // 设置Up主分组
  // 0 添加至默认分组  否则使用,分割tagid
  static const String addUsers = '/x/relation/tags/addUsers';

  static const String addSpecial = '/x/relation/tag/special/add';

  static const String delSpecial = '/x/relation/tag/special/del';

  // 获取指定分组下的up
  static const String followUpGroup = '/x/relation/tag';

  static const String createFollowTag = '/x/relation/tag/create';

  static const String updateFollowTag = '/x/relation/tag/update';

  static const String delFollowTag = '/x/relation/tag/del';

  // 获取未读私信数
  // https://api.vc.bilibili.com/session_svr/v1/session_svr/single_unread
  static const String msgUnread =
      '${HttpString.tUrl}/session_svr/v1/session_svr/single_unread';

  // 获取消息中心未读信息
  static const String msgFeedUnread = '/x/msgfeed/unread';
  //https://api.bilibili.com/x/msgfeed/reply?platform=web&build=0&mobi_app=web
  static const String msgFeedReply = '/x/msgfeed/reply';
  //https://api.bilibili.com/x/msgfeed/at?platform=web&build=0&mobi_app=web
  static const String msgFeedAt = '/x/msgfeed/at';
  //https://api.bilibili.com/x/msgfeed/like?platform=web&build=0&mobi_app=web
  static const String msgFeedLike = '/x/msgfeed/like';
  //https://message.bilibili.com/x/sys-msg/query_notify_list?page_size=20&cursor=xxx
  static const String msgSysNotify =
      '${HttpString.messageBaseUrl}/x/sys-msg/query_notify_list';

  // 系统信息光标更新（已读标记）
  //https://message.bilibili.com/x/sys-msg/update_cursor?csrf=xxxx&csrf=xxxx&cursor=1705288500000000000&has_up=0&build=0&mobi_app=web
  static const String msgSysUpdateCursor =
      '${HttpString.messageBaseUrl}/x/sys-msg/update_cursor';

  /// 私聊
  ///  'https://api.vc.bilibili.com/session_svr/v1/session_svr/get_sessions?
  /// session_type=1&
  /// group_fold=1&
  /// unfollow_fold=0&
  /// sort_rule=2&
  /// build=0&
  /// mobi_app=web&
  /// w_rid=8641d157fb9a9255eb2159f316ee39e2&
  /// wts=1697305010

  static const String sessionList =
      '${HttpString.tUrl}/session_svr/v1/session_svr/get_sessions';

  /// 私聊用户信息
  /// uids
  /// build=0&mobi_app=web
  static const String sessionAccountList =
      '${HttpString.tUrl}/account/v1/user/cards';

  /// https://api.vc.bilibili.com/svr_sync/v1/svr_sync/fetch_session_msgs?
  /// talker_id=400787461&
  /// session_type=1&
  /// size=20&
  /// sender_device_id=1&
  /// build=0&
  /// mobi_app=web&
  /// web_location=333.1296&
  /// w_rid=cfe3bf58c9fe181bbf4dd6c75175e6b0&
  /// wts=1697350697

  static const String sessionMsg =
      '${HttpString.tUrl}/svr_sync/v1/svr_sync/fetch_session_msgs';

  /// 标记已读 POST
  /// talker_id:
  /// session_type: 1
  /// ack_seqno: 920224140918926
  /// build: 0
  /// mobi_app: web
  /// csrf_token:
  /// csrf:
  static const String ackSessionMsg =
      '${HttpString.tUrl}/session_svr/v1/session_svr/update_ack';

  // 获取某个动态详情
  // timezone_offset=-480
  // id=849312409672744983
  // features=itemOpusStyle
  static const String dynamicDetail = '/x/polymer/web-dynamic/v1/detail';

  // AI总结
  /// https://api.bilibili.com/x/web-interface/view/conclusion/get?
  /// bvid=BV1ju4y1s7kn&
  /// cid=1296086601&
  /// up_mid=4641697&
  /// w_rid=1607c6c5a4a35a1297e31992220900ae&
  /// wts=1697033079
  static const String aiConclusion = '/x/web-interface/view/conclusion/get';

  // captcha验证码
  static const String getCaptcha =
      '${HttpString.passBaseUrl}/x/passport-login/captcha?source=main_web';

  // web端短信验证码
  static const String smsCode =
      '${HttpString.passBaseUrl}/x/passport-login/web/sms/send';

  // web端验证码登录

  // web端密码登录
  static const String logInByWebPwd =
      '${HttpString.passBaseUrl}/x/passport-login/web/login';

  // 获取guestID
  // static const String getGuestId = '/x/passport-user/guest/reg';

  // app端短信验证码
  static const String appSmsCode =
      '${HttpString.passBaseUrl}/x/passport-login/sms/send';

  // app端验证码登录
  static const String logInByAppSms =
      '${HttpString.passBaseUrl}/x/passport-login/login/sms';

  // 获取短信验证码
  // static const String appSafeSmsCode =
  //     'https://passport.bilibili.com/x/safecenter/common/sms/send';

  /// app端密码登录
  /// username
  /// password
  /// key
  /// salt
  static const String loginByPwdApi =
      '${HttpString.passBaseUrl}/x/passport-login/oauth2/login';

  /// 密码登录时，提示“本次登录环境存在风险, 需使用手机号进行验证或绑定”
  /// 根据https://ivan.hanloth.cn/archives/530/流程进行手机号验证
  /// tmp_code
  static const String safeCenterGetInfo =
      '${HttpString.passBaseUrl}/x/safecenter/user/info';

  /// 验证绑定手机号前的人机验证
  static const String preCapture =
      '${HttpString.passBaseUrl}/x/safecenter/captcha/pre';

  /// 密码登录时风控发送手机验证码
  ///sms_type	str	loginTelCheck
  /// tmp_code	str	验证标记代码	来自数据处理中的解析出的参数tmp_token
  /// gee_challenge	str	极验id	申请人机验证时得到(data->gee_challenge)
  /// gee_seccode	str	极验key	人机验证后得到(result->geetest_seccode)
  /// gee_validate	str	极验result	人机验证后得到(result->geetest_validate)
  /// recaptcha_token	str	验证token	申请人机验证时得到(data->recaptcha_token)
  static const String safeCenterSmsCode =
      '${HttpString.passBaseUrl}/x/safecenter/common/sms/send';

  /// type	str	loginTelCheck
  /// code	int	验证码内容
  /// tmp_code	str	验证标记代码	来自数据处理中的解析出的参数tmp_token
  /// request_id	str	验证请求标记	来自数据处理中的解析出的参数requestId
  /// captcha_key	str	验证秘钥	来自申请验证码的captcha_key（data->captcha_key）
  static const String safeCenterSmsVerify =
      '${HttpString.passBaseUrl}/x/safecenter/login/tel/verify';

  static const String oauth2AccessToken =
      '${HttpString.passBaseUrl}/x/passport-login/oauth2/access_token';

  /// 密码加密密钥
  /// disable_rcmd
  /// local_id
  static const getWebKey = '${HttpString.passBaseUrl}/x/passport-login/web/key';

  /// cookie转access_key
  static const qrcodeConfirm =
      '${HttpString.passBaseUrl}/x/passport-tv-login/h5/qrcode/confirm';

  /// 申请二维码(TV端)
  static const getTVCode =
      '${HttpString.passBaseUrl}/x/passport-tv-login/qrcode/auth_code';

  ///扫码登录（TV端）
  static const qrcodePoll =
      '${HttpString.passBaseUrl}/x/passport-tv-login/qrcode/poll';

  static const logout = '${HttpString.passBaseUrl}/login/exit/v2';

  /// 置顶视频
  static const getTopVideoApi = '/x/space/top/arc';

  /// 主页 - 最近投币的视频
  /// vmid
  /// gaia_source = main_web
  /// web_location
  /// w_rid
  /// wts
  static const getRecentCoinVideoApi = '/x/space/coin/video';

  /// 最近点赞的视频
  static const getRecentLikeVideoApi = '/x/space/like/video';

  /// 用户专栏
  static const getMemberSeasonsApi = '/x/polymer/web-space/home/seasons_series';

  /// 获赞数 播放数
  /// mid
  static const getMemberViewApi = '/x/space/upstat';

  /// 查询某个专栏
  /// mid
  /// season_id
  /// sort_reverse
  /// page_num
  /// page_size
  static const getSeasonDetailApi =
      '/x/polymer/web-space/seasons_archives_list';

  /// 获取未读动态数
  static const getUnreadDynamic = '/x/web-interface/dynamic/entrance';

  /// 用户动态主页
  static const dynamicSpmPrefix = '${HttpString.spaceBaseUrl}/1/dynamic';

  /// 激活buvid3
  static const activateBuvidApi = '/x/internal/gaia-gateway/ExClimbWuzhi';

  /// 我的订阅
  static const userSubFolder = '/x/v3/fav/folder/collected/list';

  /// 我的订阅-合集详情
  static const favSeasonList = '/x/space/fav/season/list';

  /// 发送私信
  static const String sendMsg = '${HttpString.tUrl}/web_im/v1/web_im/send_msg';

  /// 排行榜
  static const String getRankApi = "/x/web-interface/ranking/v2";

  static const String pgcRank = "/pgc/web/rank/list";

  static const String pgcSeasonRank = "/pgc/season/rank/web/list";

  /// 取消订阅-播单
  static const String unfavFolder = '/x/v3/fav/folder/unfav';

  // static const String videoTags = '/x/tag/archive/tags';
  static const String videoTags = '/x/web-interface/view/detail/tag';

  static const String reportMember = '/ajax/report/add';

  static const String removeMsg = '/session_svr/v1/session_svr/remove_session';

  static const String delSysMsg = '/x/sys-msg/del_notify_list';

  static const String delMsgfeed = '/x/msgfeed/del';

  static const String setTop = '/session_svr/v1/session_svr/set_top';

  static const String createDynamic = '/x/dynamic/feed/create/dyn';

  static const String createTextDynamic = '/dynamic_svr/v1/dynamic_svr/create';

  // static const String removeDynamic = '${HttpString.tUrl}/dynamic_svr/v1/dynamic_svr/rm_dynamic';

  static const String removeDynamic = '/x/dynamic/feed/operate/remove';

  static const String uploadBfs = '/x/dynamic/feed/draw/upload_bfs';

  static const String uploadImage = '/x/upload/web/image';

  // 点赞投币收藏关注
  static const String videoRelation = '/x/web-interface/archive/relation';

  static const String favSeason = '/x/v3/fav/season/fav';

  static const String unfavSeason = '/x/v3/fav/season/unfav';

  /// 稍后再看&收藏夹视频列表
  static const String mediaList = '/x/v2/medialist/resource/list';

  static const String pgcIndexCondition = '/pgc/season/index/condition';

  static const String pgcIndexResult = '/pgc/season/index/result';

  static const String archiveNoteList = '/x/note/publish/list/archive';

  static const String noteList = '/x/note/list';

  static const String userNoteList = '/x/note/publish/list/user';

  static const String addNote = '/x/note/add';

  static const String delNote = '/x/note/del';

  static const String delPublishNote = '/x/note/publish/del';

  static const String archiveNote = '/x/note/list/archive';

  static const String favArticle = '/x/polymer/web-dynamic/v1/opus/feed/fav';

  static const String communityAction =
      '/x/community/cosmo/interface/simple_action';

  static const String delFavArticle = '/x/article/favorites/del';

  static const String addFavArticle = '/x/article/favorites/add';

  static const String replyTop = '/x/v2/reply/top';

  static const String getCoin = '${HttpString.accountBaseUrl}/site/getCoin';

  static const String getLiveEmoticons =
      '${HttpString.liveBaseUrl}/xlive/web-ucenter/v2/emoticon/GetEmoticons';

  static const String pgcTimeline = '/pgc/web/timeline';

  static const String searchTrending = '/x/v2/search/trending/ranking';

  static const String setTopDyn = '/x/dynamic/feed/space/set_top';

  static const String rmTopDyn = '/x/dynamic/feed/space/rm_top';

  static const String searchRecommend =
      '${HttpString.appBaseUrl}/x/v2/search/recommend';

  static const String articleInfo = '/x/article/viewinfo';

  static const String dynamicReport = '/x/dynamic/feed/dynamic_report/add';

  // https://github.com/SocialSisterYi/bilibili-API-collect/pull/1242
  static const String articleView = '/x/article/view';

  static const String opusDetail = '/x/polymer/web-dynamic/v1/opus/detail';

  static const String gaiaVgateRegister = '/x/gaia-vgate/v1/register';

  static const String gaiaVgateValidate = '/x/gaia-vgate/v1/validate';

  static const String voteInfo = '/x/vote/vote_info';

  static const String doVote = '/x/vote/do_vote';

  static const String liveFeedIndex =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/index/feed';

  static const String liveFollow =
      '${HttpString.liveBaseUrl}/xlive/web-ucenter/user/following';

  static const String liveSecondList =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/second/getList';

  static const String msgSetNotice = '/x/msgfeed/notice';

  static const String liveAreaList =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/index/getAreaList';

  static const String liveRoomAreaList =
      '${HttpString.liveBaseUrl}/room/v1/Area/getList';

  static const String getLiveFavTag =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/second/get_fav_tag';

  static const String setLiveFavTag =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/second/set_fav_tag';

  static const String liveSearch =
      '${HttpString.liveBaseUrl}/xlive/app-interface/v2/search_live';

  static const String topicTop =
      '${HttpString.appBaseUrl}/x/topic/web/details/top';

  static const String topicFeed = '/x/polymer/web-dynamic/v1/feed/topic';

  static const String spaceOpus = '/x/polymer/web-dynamic/v1/opus/feed/space';

  static const String articleList = '/x/article/list/web/articles';

  static const String setMsgDnd =
      '${HttpString.tUrl}/link_setting/v1/link_setting/set_msg_dnd';

  static const String imUserInfos = '${HttpString.tUrl}/x/im/user_infos';

  static const String getSessionSs =
      '${HttpString.tUrl}/link_setting/v1/link_setting/get_session_ss';

  static const String getMsgDnd =
      '${HttpString.tUrl}/link_setting/v1/link_setting/get_msg_dnd';

  static const String setPushSs =
      '${HttpString.tUrl}/link_setting/v1/link_setting/set_push_ss';

  static const String dynReserve = '/x/dynamic/feed/reserve/click';

  static const String favPugv = '/pugv/app/web/favorite/page';

  static const String addFavPugv = '/pugv/app/web/favorite/add';

  static const String delFavPugv = '/pugv/app/web/favorite/del';

  static const String favTopicList = '/x/topic/web/fav/list';

  static const String addFavTopic = '/x/topic/fav/sub/add';

  static const String delFavTopic = '/x/topic/fav/sub/cancel';

  static const String likeTopic = '/x/topic/like';

  static const String pgcReviewL = '/pgc/review/long/list';

  static const String pgcReviewS = '/pgc/review/short/list';

  static const String pgcReviewLike = '/pgc/review/action/like';

  static const String pgcReviewDislike = '/pgc/review/action/dislike';

  static const String pgcReviewPost = '/pgc/review/short/post';

  static const String pgcReviewMod = '/pgc/review/short/modify';

  static const String pgcReviewDel = '/pgc/review/short/del';

  static const String topicPubSearch =
      '${HttpString.appBaseUrl}/x/topic/pub/search';

  static const String upowerRank = '/x/upower/up/member/rank/v2';

  static const String favFavFolder = '/x/v3/fav/folder/fav';

  static const String unfavFavFolder = '/x/v3/fav/folder/unfav';

  static const String coinArc = '${HttpString.appBaseUrl}/x/v2/space/coinarc';

  static const String likeArc = '${HttpString.appBaseUrl}/x/v2/space/likearc';

  static const String spaceSetting = '/x/space/setting/app';

  static const String spaceSettingMod = '/x/space/privacy/batch/modify';

  static const String vipExpAdd = '/x/vip/experience/add';

  static const String coinLog = '/x/member/web/coin/log';

  static const String dynTopicRcmd = '/x/topic/web/dynamic/rcmd';

  static const String matchInfo = '/x/esports/match/info';

  static const String dynPic = '/x/polymer/web-dynamic/v1/detail/pic';

  static const String msgLikeDetail = '/x/msgfeed/like_detail';

  static const String getLiveInfoByUser =
      '${HttpString.liveBaseUrl}/xlive/web-room/v1/index/getInfoByUser';

  static const String liveSetSilent =
      '${HttpString.liveBaseUrl}/liveact/user_silent';

  static const String addShieldKeyword =
      '${HttpString.liveBaseUrl}/xlive/web-ucenter/v1/banned/AddShieldKeyword';

  static const String delShieldKeyword =
      '${HttpString.liveBaseUrl}/xlive/web-ucenter/v1/banned/DelShieldKeyword';

  static const String liveShieldUser =
      '${HttpString.liveBaseUrl}/liveact/shield_user';

  static const String spaceComic = '${HttpString.appBaseUrl}/x/v2/space/comic';

  static const String spaceAudio = '/audio/music-service/web/song/upper';

  static const String spaceCheese = '/pugv/app/web/season/page';

  static const String dynMention = '/x/polymer/web-dynamic/v1/mention/search';

  static const String createVote = '/x/vote/create';

  static const String updateVote = '/x/vote/update';

  static const String createReserve = '/x/new-reserve/up/reserve/create';

  static const String updateReserve = '/x/new-reserve/up/reserve/update';

  static const String reserveInfo = '/x/new-reserve/up/reserve/info';

  static const String loginLog = '/x/member/web/login/log';

  static const String expLog = '/x/member/web/exp/log';

  static const String moralLog = '/x/member/web/moral/log';

  static const String liveLikeReport =
      '${HttpString.liveBaseUrl}/xlive/app-ucenter/v1/like_info_v3/like/likeReportV3';

  static const String loginDevices =
      '${HttpString.passBaseUrl}/x/safecenter/user_login_devices';

  static const String bgmDetail = '/x/copyright-music-publicity/bgm/detail';

  static const String wishUpdate =
      '/x/copyright-music-publicity/bgm/wish/update';

  static const String bgmRecommend =
      '/x/copyright-music-publicity/bgm/recommend_list';

  static const String spaceShop =
      '${HttpString.mallBaseUrl}/community-hub/small_shop/feed/tab/item';

  static const String superChatMsg =
      '${HttpString.liveBaseUrl}/av/v1/SuperChat/getMessageList';

  static const String popularSeriesOne = '/x/web-interface/popular/series/one';

  static const String popularSeriesList =
      '/x/web-interface/popular/series/list';

  static const String popularPrecious = '/x/web-interface/popular/precious';

  static const String userRealName = '/x/member/app/up/realname';

  static const String liveDmReport =
      '${HttpString.liveBaseUrl}/xlive/web-ucenter/v1/dMReport/Report';

  static const String danmakuLike = '/x/v2/dm/thumbup/add';

  static const String danmakuReport = '/x/dm/report/add';

  static const String danmakuRecall = '/x/dm/recall';

  static const String danmakuEditState = '/x/v2/dm/edit/state';

  static const String followedUp = '/x/relation/followings/followed_upper';

  static const String sameFollowing = '/x/relation/same/followings';
}
