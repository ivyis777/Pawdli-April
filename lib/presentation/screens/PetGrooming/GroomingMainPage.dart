import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/PetGrooming/FloatingServiceCartButton.dart';
import 'package:pawlli/presentation/screens/PetGrooming/OneTimeService/GroomingOneTimeServicePage.dart';
import 'package:pawlli/presentation/screens/PetGrooming/GroomingPlanPage.dart';
import 'package:pawlli/presentation/screens/PetWalker/walkerDetailsPage.dart';

double getResponsiveFont(BuildContext context, double size) {
  double screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 360) {
    return size * 0.85;
  } else if (screenWidth < 400) {
    return size;
  } else if (screenWidth < 600) {
    return size * 1.1;
  } else {
    return size * 1.3;
  }
}

class PetServicesPage extends StatefulWidget {
  const PetServicesPage({super.key});

  @override
  State<PetServicesPage> createState() => _PetServicesPageState();
}

class _PetServicesPageState extends State<PetServicesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int selectedTab = 0;
  int selectedPromotion = 0;

  final PageController promotionController = PageController(
    viewportFraction: 0.92,
  );

  final List<String> promotionImages = [
    "https://app.pawdli.com/media/static/yellowcard.png",
    "https://app.pawdli.com/media/static/browncard.png",
    "https://app.pawdli.com/media/static/yellowcard.png",
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    promotionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.secondarycolour,

      /// APP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colours.brownColour,

          flexibleSpace: Stack(
            children: [
              SizedBox(
                width: 250,
                height: 100,
                child: Image.network(
                  "https://app.pawdli.com/media/static/topimage.png",
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          title: Text(
            "Pet Services",
            style: TextStyle(
              fontFamily: FontFamily.Cairo,
              color: Colours.brownColour,
              fontSize: getResponsiveFont(context, 18),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          Column(
            children: [
              // GROOMING / WALKER TABS
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildTabBar(),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGroomingScreen(),
                    _buildWalkerScreen(),
                  ],
                ),
              ),
            ],
          ),

          // Floating cart button
          const FloatingGroomingCart(),
        ],
      ),
    );
  }

  // ============================================================
  // TAB BAR
  // ============================================================

  Widget _buildTabBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,

        dividerColor: Colors.transparent,

        indicatorSize: TabBarIndicatorSize.tab,

        indicator: BoxDecoration(
          color: Colours.primarycolour,
          borderRadius: BorderRadius.circular(13),
        ),

        labelColor: Colors.white,
        unselectedLabelColor: Colours.brownColour,

        labelStyle: TextStyle(
          fontFamily: FontFamily.Cairo,
          fontSize: getResponsiveFont(context, 15),
          fontWeight: FontWeight.w600,
        ),

        unselectedLabelStyle: TextStyle(
          fontFamily: FontFamily.Cairo,
          fontSize: getResponsiveFont(context, 15),
          fontWeight: FontWeight.w500,
        ),

        tabs: const [
          Tab(
            text: "Grooming",
          ),
          Tab(
            text: "Walker",
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GROOMING SCREEN
  // ============================================================

  Widget _buildGroomingScreen() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// PROMOTION
          _buildPromotionSection(
            title: "Grooming Offers",
          ),

          const SizedBox(height: 20),

          /// TITLE
          _sectionTitle(
            "Grooming Plans",
          ),

          const SizedBox(height: 12),

          /// BUILD GROOMING PLAN
          _serviceCard(
            title: "Build Grooming Plan",
            subtitle:
                "Create a grooming plan specially designed for your pet.",
            icon: Icons.content_cut_rounded,
            buttonText: "Try Now",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuildGroomingPlanPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          /// ONE TIME SERVICE
          _serviceCard(
            title: "One Time Grooming Service",
            subtitle:
                "Bath, haircut, nail trimming and complete grooming in one visit.",
            icon: Icons.pets_rounded,
            buttonText: "Try Now",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OneTimeGroomingServicePage(),
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          _buildReviewSection(
            serviceType: "Grooming",
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WALKER SCREEN
  // ============================================================

  Widget _buildWalkerScreen() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// PROMOTION
          _buildPromotionSection(
            title: "Walker Offers",
          ),

          const SizedBox(height: 20),

          _sectionTitle(
            "Walking Plans",
          ),

          const SizedBox(height: 12),

          /// WALKING PLAN
          _serviceCard(
            title: "Walking Plan Service",
            subtitle:
                "Choose a regular walking schedule for your pet.",
            icon: Icons.directions_walk_rounded,
            buttonText: "View",
            onTap: () {
              Get.to(
                () => WalkerDetailsPage(),
              );
            },
          ),

          const SizedBox(height: 14),

          /// SINGLE WALK
          _serviceCard(
            title: "Single Walk Service",
            subtitle:
                "Book a professional walker for a one-time pet walk.",
            icon: Icons.pets_rounded,
            buttonText: "View",
            onTap: () {
              Get.to(
                () => WalkerDetailsPage(),
              );
            },
          ),

          const SizedBox(height: 22),

          _buildReviewSection(
            serviceType: "Walking",
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROMOTION SECTION
  // ============================================================

  Widget _buildPromotionSection({
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        _sectionTitle(title),

        const SizedBox(height: 10),

        SizedBox(
          height: 165,
          child: PageView.builder(
            controller: promotionController,
            itemCount: promotionImages.length,
            onPageChanged: (index) {
              setState(() {
                selectedPromotion = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        promotionImages[index],
                        fit: BoxFit.fill,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 18,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedTab == 0
                                        ? "Pamper Your Pet"
                                        : "Healthy Walk, Happy Pet",
                                    style: TextStyle(
                                      fontFamily:
                                          FontFamily.Cairo,
                                      fontSize:
                                          getResponsiveFont(
                                              context, 17),
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colours
                                          .secondarycolour,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    selectedTab == 0
                                        ? "Professional grooming\nat special prices"
                                        : "Professional walking\nservices for your pet",
                                    style: TextStyle(
                                      fontFamily:
                                          FontFamily.Cairo,
                                      fontSize:
                                          getResponsiveFont(
                                              context, 13),
                                      color: Colours
                                          .secondarycolour,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colours.primarycolour,
                                      borderRadius:
                                          BorderRadius.circular(
                                              20),
                                    ),
                                    child: Text(
                                      "Explore Now",
                                      style: TextStyle(
                                        fontFamily:
                                            FontFamily.Cairo,
                                        color: Colors.white,
                                        fontSize:
                                            getResponsiveFont(
                                                context, 12),
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        /// DOT INDICATORS
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            promotionImages.length,
            (index) {
              bool active =
                  selectedPromotion == index;

              return AnimatedContainer(
                duration:
                    const Duration(milliseconds: 250),
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                height: 7,
                width: active ? 22 : 7,
                decoration: BoxDecoration(
                  color: active
                      ? Colours.primarycolour
                      : Colours.brownColour
                          .withOpacity(0.25),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SERVICE CARD
  // ============================================================

  Widget _serviceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            /// ICON
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: Colours.primarycolour
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colours.primarycolour,
              ),
            ),

            const SizedBox(width: 14),

            /// INFORMATION
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: FontFamily.Cairo,
                      color: Colours.brownColour,
                      fontSize:
                          getResponsiveFont(
                              context, 15),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: FontFamily.Cairo,
                      color: Colours.brownColour
                          .withOpacity(0.65),
                      fontSize:
                          getResponsiveFont(
                              context, 11),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            /// BUTTON
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colours.primarycolour,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontFamily: FontFamily.Cairo,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize:
                        getResponsiveFont(
                            context, 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REVIEWS
  // ============================================================

  Widget _buildReviewSection({
    required String serviceType,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          "Customer Reviews & Ratings",
        ),

        const SizedBox(height: 12),

        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Container(
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset:
                      const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              children: [
                /// RATING HEADER
                Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colours
                            .primarycolour
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color:
                            Colours.primarycolour,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            "4.8",
                            style: TextStyle(
                              fontFamily:
                                  FontFamily.Cairo,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colours
                                  .brownColour,
                              fontSize:
                                  getResponsiveFont(
                                      context,
                                      20),
                            ),
                          ),
                          Text(
                            "Based on 120 reviews",
                            style: TextStyle(
                              fontFamily:
                                  FontFamily.Cairo,
                              color: Colours
                                  .brownColour
                                  .withOpacity(
                                      0.6),
                              fontSize:
                                  getResponsiveFont(
                                      context,
                                      11),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      "⭐⭐⭐⭐⭐",
                      style: TextStyle(
                        fontSize:
                            getResponsiveFont(
                                context, 15),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Divider(
                  color:
                      Colours.brownColour
                          .withOpacity(0.1),
                ),

                const SizedBox(height: 12),

                _reviewItem(
                  name: "Thilak",
                  rating: "5.0",
                  text: serviceType ==
                          "Grooming"
                      ? "Very good grooming service. My pet looked clean and happy."
                      : "The walker was very friendly and handled my pet very well.",
                ),

                const SizedBox(height: 15),

                _reviewItem(
                  name: "Karthik",
                  rating: "4.8",
                  text: serviceType ==
                          "Grooming"
                      ? "Professional groomer and excellent service."
                      : "Very punctual and professional walking service.",
                ),

                const SizedBox(height: 18),

                /// CUSTOMER PHOTOS
                Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    "Customer Photos",
                    style: TextStyle(
                      fontFamily:
                          FontFamily.Cairo,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colours.brownColour,
                      fontSize:
                          getResponsiveFont(
                              context, 14),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection:
                        Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder:
                        (context, index) =>
                            const SizedBox(
                                width: 10),
                    itemBuilder:
                        (context, index) {
                      return Container(
                        height: 80,
                        width: 80,
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius
                                  .circular(14),
                          color: Colours
                              .primarycolour
                              .withOpacity(
                                  0.12),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(14),
                          child: Image.asset(
                            "assets/images/applogo.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewItem({
    required String name,
    required String rating,
    required String text,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor:
              Colours.primarycolour
                  .withOpacity(0.12),
          child: Icon(
            Icons.person,
            color: Colours.primarycolour,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontFamily:
                            FontFamily.Cairo,
                        fontWeight:
                            FontWeight.bold,
                        color: Colours
                            .brownColour,
                        fontSize:
                            getResponsiveFont(
                                context, 13),
                      ),
                    ),
                  ),

                  Text(
                    "⭐ $rating",
                    style: TextStyle(
                      fontFamily:
                          FontFamily.Cairo,
                      color:
                          Colours.brownColour,
                      fontSize:
                          getResponsiveFont(
                              context, 11),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                text,
                style: TextStyle(
                  fontFamily:
                      FontFamily.Cairo,
                  color: Colours
                      .brownColour
                      .withOpacity(0.65),
                  fontSize:
                      getResponsiveFont(
                          context, 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: FontFamily.Cairo,
          color: Colours.brownColour,
          fontWeight: FontWeight.bold,
          fontSize:
              getResponsiveFont(
                  context, 17),
        ),
      ),
    );
  }
}