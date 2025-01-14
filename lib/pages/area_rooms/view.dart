import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hot_live/common/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AreasRoomPage extends StatefulWidget {
  const AreasRoomPage({Key? key, required this.area}) : super(key: key);

  final AreaInfo area;

  @override
  State<AreasRoomPage> createState() => _AreasRoomPageState();
}

class _AreasRoomPageState extends State<AreasRoomPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<RoomInfo> roomsList = [];
  int pageIndex = 1;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  void _onRefresh() async {
    pageIndex = 0;
    final items = await LiveApi.getAreaRooms(widget.area, page: pageIndex);
    if (items.isEmpty) {
      _refreshController.refreshFailed();
    } else {
      roomsList.clear();
      roomsList.addAll(items);
      _refreshController.refreshCompleted();
    }
    setState(() {});
  }

  void _onLoading() async {
    pageIndex++;
    final items = await LiveApi.getAreaRooms(widget.area, page: pageIndex);
    if (items.isEmpty) {
      _refreshController.loadFailed();
    } else {
      for (var item in items) {
        if (roomsList.indexWhere((e) => e.roomId == item.roomId) != -1) {
          continue;
        }
        roomsList.add(item);
      }
      _refreshController.loadComplete();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1280
        ? 8
        : (screenWidth > 960 ? 6 : (screenWidth > 640 ? 4 : 2));

    return Scaffold(
      appBar: AppBar(title: Text(widget.area.areaName)),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: const OnLoadingFooter(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: roomsList.isNotEmpty
            ? MasonryGridView.count(
                padding: const EdgeInsets.all(5),
                controller: ScrollController(),
                crossAxisCount: crossAxisCount,
                itemCount: roomsList.length,
                itemBuilder: (context, index) =>
                    RoomCard(room: roomsList[index], dense: true),
              )
            : EmptyView(
                icon: Icons.live_tv_rounded,
                title: S.of(context).empty_areas_room_title,
                subtitle: S.of(context).empty_areas_room_subtitle,
              ),
      ),
    );
  }
}
