import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/skeleton/dynamic_card.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/no_data.dart';
import 'package:pilipala/pages/dynamics/widgets/dynamic_panel.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'controller.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({super.key});

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage>
    with AutomaticKeepAliveClientMixin {
  final FollowController _controller = Get.put(FollowController());
  late Future _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _controller.queryFollowDynamic();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('关注动态'),
        actions: [
          // 筛选按钮
          Obx(() => Stack(
            children: [
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () => _showFilterBottomSheet(),
              ),
              if (_controller.selectedGroups.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_controller.selectedGroups.length}',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          )),
          // 隐藏已读开关
          Obx(() => Switch(
            value: _controller.hideReadItems.value,
            onChanged: (value) => _controller.toggleHideRead(),
          )),
        ],
      ),
      body: Column(
        children: [
          // 已选分组显示
          _buildSelectedGroupsChips(),
          // 信息流列表
          Expanded(
            child: _buildContentList(),
          ),
        ],
      ),
    );
  }

  // 已选分组显示
  Widget _buildSelectedGroupsChips() {
    return Obx(() {
      if (_controller.selectedGroups.isEmpty) {
        return SizedBox.shrink();
      }
      
      return Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _controller.selectedGroups.length,
          itemBuilder: (context, index) {
            String groupId = _controller.selectedGroups[index];
            var group = _controller.allGroups.firstWhere((g) => g.id == groupId);
            return Container(
              margin: EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(group.name),
                deleteIcon: Icon(Icons.close, size: 16),
                onDeleted: () => _controller.toggleGroup(groupId),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            );
          },
        ),
      );
    });
  }

  // 信息流列表
  Widget _buildContentList() {
    return FutureBuilder(
      future: _futureBuilderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return const SliverToBoxAdapter(child: SizedBox());
          }
          Map? data = snapshot.data;
          if (data != null && data['status']) {
            return Obx(() {
              if (_controller.filteredList.isEmpty) {
                if (_controller.isLoadingFollow.value) {
                  return _buildSkeleton();
                } else {
                  return _buildEmptyState();
                }
              } else {
                return RefreshIndicator(
                  onRefresh: _controller.refreshData,
                  child: ListView.builder(
                    controller: _controller.scrollController,
                    itemCount: _controller.filteredList.length,
                    itemBuilder: (context, index) {
                      var item = _controller.filteredList[index];
                      return _buildFollowItem(item);
                    },
                  ),
                );
              }
            });
          } else {
            return HttpError(
              errMsg: data?['msg'] ?? '请求异常',
              btnText: data?['code'] == -101 ? '去登录' : null,
              fn: () {},
            );
          }
        } else {
          return _buildSkeleton();
        }
      },
    );
  }

  // 关注动态项
  Widget _buildFollowItem(dynamic item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.grey.withOpacity(0.05) : null,
        borderRadius: BorderRadius.circular(12),
        border: item.isRead ? null : Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _controller.pushDetail(item),
          onLongPress: () => _showItemMenu(item),
          child: Column(
            children: [
              // 复用现有的DynamicPanel
              DynamicPanel(item: item),
              // 已读状态指示器
              if (!item.isRead)
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 底部筛选面板
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '选择分组',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // 快捷操作
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _controller.toggleAllGroups,
                    child: Text('全选'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _controller.clearAllGroups,
                    child: Text('清空'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // 分组列表
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: _controller.allGroups.length,
                itemBuilder: (context, index) {
                  var group = _controller.allGroups[index];
                  bool isSelected = _controller.selectedGroups.contains(group.id);
                  
                  return CheckboxListTile(
                    title: Text(group.name),
                    subtitle: Text('${group.followCount}人关注 · ${group.unreadCount}条未读'),
                    value: isSelected,
                    onChanged: (value) => _controller.toggleGroup(group.id),
                    secondary: CircleAvatar(
                      backgroundColor: group.color.withOpacity(0.1),
                      child: Icon(
                        group.icon,
                        color: group.color,
                        size: 20,
                      ),
                    ),
                  );
                },
              )),
            ),
            
            // 确定按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _controller.applyFilter();
                  Navigator.pop(context);
                },
                child: Text('确定 (${_controller.selectedGroups.length})'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 长按菜单
  void _showItemMenu(dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!item.isRead)
              ListTile(
                leading: Icon(Icons.mark_email_read),
                title: Text('标记已读'),
                onTap: () {
                  _controller.markAsRead(item);
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('移动到分组'),
              onTap: () {
                Navigator.pop(context);
                _showGroupSelector(item);
              },
            ),
            ListTile(
              leading: Icon(Icons.block),
              title: Text('不再关注'),
              onTap: () {
                _controller.unfollow(item.modules.moduleAuthor.mid.toString());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 分组选择器
  void _showGroupSelector(dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择分组',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            ..._controller.allGroups.map((group) => ListTile(
              leading: CircleAvatar(
                backgroundColor: group.color.withOpacity(0.1),
                child: Icon(group.icon, color: group.color),
              ),
              title: Text(group.name),
              onTap: () {
                // TODO: 实现移动分组逻辑
                Navigator.pop(context);
                SmartDialog.showToast('移动分组功能待实现');
              },
            )),
          ],
        ),
      ),
    );
  }

  // 骨架屏
  Widget _buildSkeleton() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return const DynamicCardSkeleton();
      },
      itemCount: 5,
    );
  }

  // 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无关注动态',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '去关注一些UP主吧',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}