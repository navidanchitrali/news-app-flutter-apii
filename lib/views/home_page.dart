import 'package:carousel_slider/carousel_slider.dart';
 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_room_app_getx/constants/color_constants.dart';
import 'package:news_room_app_getx/constants/size_constants.dart';
import 'package:news_room_app_getx/constants/ui_constants.dart';
import 'dart:math' as math;

import 'package:news_room_app_getx/contollers/news_controller.dart';
import 'package:news_room_app_getx/views/web_view_news.dart';
import 'package:news_room_app_getx/widgets/custom_appBar.dart';
import 'package:news_room_app_getx/widgets/news_card.dart';
import 'package:news_room_app_getx/widgets/side_drawer.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  NewsController newsController = Get.put(NewsController());

  TextEditingController searchController = TextEditingController();

  late AnimationController _xControllerForChild;
  late Animation<double> _yRotationAnimationForChild;

  late AnimationController _xControllerForDrawer;
  late Animation<double> _yRotationAnimationForDrawer;

  @override
  void initState() {
    super.initState();
    _xControllerForChild = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _yRotationAnimationForChild = Tween<double>(
      begin: 0,
      end: -math.pi / 2,
    ).animate(_xControllerForChild);

    _xControllerForDrawer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _yRotationAnimationForDrawer = Tween<double>(
      begin: math.pi / 2.7,
      end: 0,
    ).animate(_xControllerForDrawer);
  }

  @override
  void dispose() {
    _xControllerForChild.dispose();
    _xControllerForDrawer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDrag = screenWidth * 0.8;
    return Scaffold(
         appBar: customAppBar('News Room', context, actions: [
          IconButton(
            onPressed: () {
              newsController.country.value = '';
              newsController.category.value = '';
              newsController.searchNews.value = '';
              newsController.channel.value = '';
              newsController.cName.value = '';
              newsController.getAllNews(reload: true);
              newsController.getBreakingNews(reload: true);
              newsController.update();
            },
            icon: const Icon(Icons.refresh),
          ),
        ]),
        body: GestureDetector(
          onHorizontalDragUpdate: (details) {
            final delta = details.delta.dx / maxDrag;
            _xControllerForChild.value += delta;
            _xControllerForDrawer.value += delta;
          },
          onHorizontalDragEnd: (details) {
            if (_xControllerForChild.value < 0.5) {
              _xControllerForChild.reverse();
              _xControllerForDrawer.reverse();
            } else {
              _xControllerForChild.forward();
              _xControllerForDrawer.forward();
            }
          },
          child: AnimatedBuilder(
              animation: Listenable.merge([
                _xControllerForChild,
                _xControllerForDrawer,
              ]),
              builder: (context, child) {
                return Stack(
                  children: [
                    Container(
                      color: const Color(0xFF1a1b26),
                    ),
                    Transform(
                      alignment: Alignment.centerLeft,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..translate(_xControllerForChild.value * maxDrag)
                        ..rotateY(_yRotationAnimationForChild.value),
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Sizes.dimen_8),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: Sizes.dimen_18,
                                    vertical: Sizes.dimen_16),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(Sizes.dimen_8)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      fit: FlexFit.tight,
                                      flex: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: Sizes.dimen_16),
                                        child: TextField(
                                          controller: searchController,
                                          textInputAction:
                                              TextInputAction.search,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Search News"),
                                          onChanged: (val) {
                                            newsController.searchNews.value =
                                                val;
                                            newsController.update();
                                          },
                                          onSubmitted: (value) async {
                                            newsController.searchNews.value =
                                                value;
                                            await newsController.getAllNews(
                                                searchKey: newsController
                                                    .searchNews.value);
                                            searchController.clear();
                                          },
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: IconButton(
                                          padding: EdgeInsets.zero,
                                          color: AppColors.bluebackground,
                                          onPressed: () async {
                                            newsController.getAllNews(
                                                searchKey: newsController
                                                    .searchNews.value);
                                            searchController.clear();
                                          },
                                          icon: const Icon(Icons.search_sharp)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GetBuilder<NewsController>(
                                init: NewsController(),
                                builder: (controller) {
                                  return CarouselSlider(
                                    options: CarouselOptions(
                                        height: 200,
                                        autoPlay: true,
                                        enlargeCenterPage: true),
                                    items:
                                        controller.breakingNews.map((instance) {
                                      return controller.articleNotFound.value
                                          ? const Center(
                                              child: Text("Not Found",
                                                  style:
                                                      TextStyle(fontSize: 30)))
                                          : controller.breakingNews.isEmpty
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : Builder(builder:
                                                  (BuildContext context) {
                                                  try {
                                                    return Banner(
                                                      location: BannerLocation
                                                          .topStart,
                                                      message: 'Top Headlines',
                                                      child: InkWell(
                                                        onTap: () => Get.to(
                                                            () => WebViewNews(
                                                                newsUrl:
                                                                    instance
                                                                        .url)),
                                                        child: Stack(children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                Image.network(
                                                              instance.urlToImage ??
                                                                  " ",
                                                              fit: BoxFit.fill,
                                                              height: double
                                                                  .infinity,
                                                              width: double
                                                                  .infinity,
                                                              errorBuilder: (BuildContext
                                                                      context,
                                                                  Object
                                                                      exception,
                                                                  StackTrace?
                                                                      stackTrace) {
                                                                return Card(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child:
                                                                      const SizedBox(
                                                                    height: 200,
                                                                    width: double
                                                                        .infinity,
                                                                    child: Icon(
                                                                        Icons
                                                                            .broken_image_outlined),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          Positioned(
                                                              left: 0,
                                                              right: 0,
                                                              bottom: 0,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    gradient: LinearGradient(
                                                                        colors: [
                                                                          Colors
                                                                              .black12
                                                                              .withOpacity(0),
                                                                          Colors
                                                                              .black
                                                                        ],
                                                                        begin: Alignment
                                                                            .topCenter,
                                                                        end: Alignment
                                                                            .bottomCenter)),
                                                                child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                                                    child: Container(
                                                                        margin: const EdgeInsets.symmetric(horizontal: 10),
                                                                        child: Text(
                                                                          instance
                                                                              .title,
                                                                          style: const TextStyle(
                                                                              fontSize: Sizes.dimen_16,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold),
                                                                        ))),
                                                              )),
                                                        ]),
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    if (kDebugMode) {
                                                      print(e);
                                                    }
                                                    return Container();
                                                  }
                                                });
                                    }).toList(),
                                  );
                                }),
                            vertical10,
                            const Divider(),
                            vertical10,
                            newsController.cName.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: Sizes.dimen_18),
                                    child: Obx(() {
                                      return Text(
                                        newsController.cName.value
                                            .toUpperCase(),
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                            fontSize: Sizes.dimen_20,
                                            fontWeight: FontWeight.bold),
                                      );
                                    }),
                                  )
                                : const SizedBox.shrink(),
                            vertical10,
                            GetBuilder<NewsController>(
                                init: NewsController(),
                                builder: (controller) {
                                  return controller.articleNotFound.value
                                      ? const Center(
                                          child: Text('Nothing Found'),
                                        )
                                      : controller.allNews.isEmpty
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : ListView.builder(
                                              controller:
                                                  controller.scrollController,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                                  controller.allNews.length,
                                              itemBuilder: (context, index) {
                                                index ==
                                                            controller.allNews
                                                                    .length -
                                                                1 &&
                                                        controller
                                                            .isLoading.isTrue
                                                    ? const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      )
                                                    : const SizedBox();
                                                return InkWell(
                                                  onTap: () => Get.to(() =>
                                                      WebViewNews(
                                                          newsUrl: controller
                                                              .allNews[index]
                                                              .url)),
                                                  child: NewsCard(
                                                      imgUrl: controller
                                                              .allNews[index]
                                                              .urlToImage ??
                                                          '',
                                                      desc: controller
                                                              .allNews[index]
                                                              .description ??
                                                          '',
                                                      title: controller
                                                          .allNews[index].title,
                                                      content: controller
                                                              .allNews[index]
                                                              .content ??
                                                          '',
                                                      postUrl: controller
                                                          .allNews[index].url),
                                                );
                                              });
                                }),
                          ],
                        ),
                      ),
                    ),
                    Transform(
                      alignment: Alignment.centerRight,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..translate(-screenWidth +
                            _xControllerForDrawer.value * maxDrag)
                        ..rotateY(_yRotationAnimationForDrawer.value),
                      child: sideDrawer(newsController),
                    ),
                  ],
                );
              }),
        ));
  }
}
