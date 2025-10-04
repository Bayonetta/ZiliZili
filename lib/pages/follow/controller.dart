// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/http/dynamics.dart';
import 'package:pilipala/models/dynamics/result.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/route_push.dart';
import 'package:pilipala/utils/storage.dart';

class FollowController extends GetxController {
  int page = 1;
  String? offset = '';
  RxList<DynamicItemModel> followList = <DynamicItemModel>[].obs;
  RxList<DynamicItemModel> filteredList = <DynamicItemModel>[].obs;
  RxList<FollowGroup> allGroups = <FollowGroup>[].obs;
  RxList<String> selectedGroups = <String>[].obs;
  RxBool hideReadItems = false.obs;
  RxBool isLoadingFollow = false.obs;
  final ScrollController scrollController = ScrollController();
  
  Box userInfoCache = GStrorage.userInfo;
  RxBool userLogin = false.obs;
  var userInfo;

  @override
  void onInit() {
    userInfo = userInfoCache.get('userInfoCache');
    userLogin.value = userInfo != null;
    super.onInit();
    _initGroups();
  }

  // 初始化分组数据
  void _initGroups() {
    allGroups.value = [
      FollowGroup(id: 'all', name: '全部', icon: Icons.all_inclusive, color: Colors.blue, followCount: 0, unreadCount: 0),
      FollowGroup(id: 'tech', name: '科技', icon: Icons.smartphone, color: Colors.green, followCount: 0, unreadCount: 0),
      FollowGroup(id: 'game', name: '游戏', icon: Icons.games, color: Colors.orange, followCount: 0, unreadCount: 0),
      FollowGroup(id: 'life', name: '生活', icon: Icons.home, color: Colors.purple, followCount: 0, unreadCount: 0),
      FollowGroup(id: 'study', name: '学习', icon: Icons.school, color: Colors.red, followCount: 0, unreadCount: 0),
      FollowGroup(id: 'unclassified', name: '未分组', icon: Icons.folder_open, color: Colors.grey, followCount: 0, unreadCount: 0),
    ];
  }

  // 获取关注动态
  Future queryFollowDynamic({type = 'init'}) async {
    if (!userLogin.value) {
      return {'status': false, 'msg': '账号未登录', 'code': -101};
    }
    if (type == 'init') {
      followList.clear();
    }
    // 下拉刷新数据渲染时会触发onLoad
    if (type == 'onLoad' && page == 1) {
      return;
    }
    isLoadingFollow.value = true;
    var res = await DynamicsHttp.followDynamic(
      page: type == 'init' ? 1 : page,
      type: 'all',
      offset: offset,
    );
    isLoadingFollow.value = false;
    if (res['status']) {
      if (type == 'onLoad' && res['data'].items.isEmpty) {
        SmartDialog.showToast('没有更多了');
        return;
      }
      if (type == 'init') {
        followList.value = res['data'].items;
        _addReadStatusToItems();
      } else {
        followList.addAll(res['data'].items);
        _addReadStatusToItems();
      }
      offset = res['data'].offset;
      page++;
      _updateGroupStats();
      _filterContent();
    }
    return res;
  }

  // 为动态项添加已读状态
  void _addReadStatusToItems() {
    for (var item in followList) {
      if (!item.isRead) {
        item.isRead = _isItemRead(item.id);
      }
    }
  }

  // 检查项目是否已读
  bool _isItemRead(String itemId) {
    Box readStatusBox = GStrorage.readStatus;
    return readStatusBox.get(itemId, defaultValue: false);
  }

  // 标记为已读
  void markAsRead(DynamicItemModel item) {
    item.isRead = true;
    Box readStatusBox = GStrorage.readStatus;
    readStatusBox.put(item.id, true);
    readStatusBox.put('${item.id}_readTime', DateTime.now().millisecondsSinceEpoch);
    _updateGroupStats();
    _filterContent();
  }

  // 切换隐藏已读
  void toggleHideRead() {
    hideReadItems.value = !hideReadItems.value;
    _filterContent();
  }

  // 切换分组选择
  void toggleGroup(String groupId) {
    if (selectedGroups.contains(groupId)) {
      selectedGroups.remove(groupId);
    } else {
      selectedGroups.add(groupId);
    }
    _filterContent();
  }

  // 全选分组
  void toggleAllGroups() {
    if (selectedGroups.length == allGroups.length) {
      selectedGroups.clear();
    } else {
      selectedGroups.value = allGroups.map((g) => g.id).toList();
    }
    _filterContent();
  }

  // 清空选择
  void clearAllGroups() {
    selectedGroups.clear();
    _filterContent();
  }

  // 应用筛选
  void applyFilter() {
    _filterContent();
  }

  // 筛选内容
  void _filterContent() {
    List<DynamicItemModel> result = followList;
    
    // 按分组筛选
    if (selectedGroups.isNotEmpty) {
      result = result.where((item) {
        return selectedGroups.contains(item.groupId) || 
               (selectedGroups.contains('all') && item.groupId != null);
      }).toList();
    }
    
    // 隐藏已读
    if (hideReadItems.value) {
      result = result.where((item) => !item.isRead).toList();
    }
    
    filteredList.value = result;
  }

  // 更新分组统计
  void _updateGroupStats() {
    for (var group in allGroups) {
      group.followCount = 0;
      group.unreadCount = 0;
    }
    
    for (var item in followList) {
      String groupId = item.groupId ?? 'unclassified';
      var group = allGroups.firstWhere((g) => g.id == groupId, orElse: () => allGroups.last);
      group.followCount++;
      if (!item.isRead) {
        group.unreadCount++;
      }
    }
    
    // 更新全部分组统计
    var allGroup = allGroups.first;
    allGroup.followCount = followList.length;
    allGroup.unreadCount = followList.where((item) => !item.isRead).length;
  }

  // 刷新数据
  Future<void> refreshData() async {
    page = 1;
    offset = '';
    await queryFollowDynamic(type: 'init');
  }

  // 跳转到详情
  void pushDetail(DynamicItemModel item) {
    // 标记为已读
    if (!item.isRead) {
      markAsRead(item);
    }
    // 跳转到详情页
    RoutePush.pushDetail(item, 1);
  }

  // 取消关注
  void unfollow(String authorId) {
    // TODO: 实现取消关注逻辑
    SmartDialog.showToast('取消关注功能待实现');
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}

// 关注分组模型
class FollowGroup {
  String id;
  String name;
  IconData icon;
  Color color;
  int followCount;
  int unreadCount;

  FollowGroup({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.followCount = 0,
    this.unreadCount = 0,
  });
}