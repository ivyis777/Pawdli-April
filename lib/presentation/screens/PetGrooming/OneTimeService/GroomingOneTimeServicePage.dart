import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/GroomingOneTimeServiceController.dart';
import 'package:pawlli/data/controller/GroomingServicePlansController.dart';
import 'package:pawlli/data/model/GroomingServicePlansModel.dart';
import 'package:pawlli/data/model/ServiceCartModel.dart';
import 'package:pawlli/presentation/screens/PetGrooming/OneTimeService/GroomingOneTimeServiceDetailsPage.dart';
import 'package:pawlli/presentation/screens/PetGrooming/OneTimeService/OnetimeServiceAddDetailspage.dart';

class OneTimeGroomingServicePage extends StatefulWidget {
  final int? editCartItemId;
  final List<int> existingPackageIds;
  final GroomingCartItemModel? existingCartItem;
  final List<GroomingCartItemModel> existingCartItems;

  const OneTimeGroomingServicePage({
    super.key,
    this.editCartItemId,
    this.existingPackageIds = const [],
    this.existingCartItem,
    this.existingCartItems = const [],
  });

  bool get isEditMode => editCartItemId != null;

  @override
  State<OneTimeGroomingServicePage> createState() =>
      _OneTimeGroomingServicePageState();
}

class _OneTimeGroomingServicePageState

    extends State<OneTimeGroomingServicePage> {

  late final OneTimeGroomingServiceController categoryController;

  late final GroomingServiceController detailsController;

  int selectedTab = 0;

  final ScrollController _scrollController = ScrollController();

  final Map<int, GlobalKey> _sectionKeys = {};

  final Map<int, GroomingServiceModel> _allServiceDetails = {};

  bool _isLoadingAllDetails = false;
  final Set<OneTimeGroomingPackage> _selectedPackages = {};
  final Map<OneTimeGroomingPackage, int> _packageMainServiceIds = {};

  @override

  void initState() {

    super.initState();

    categoryController =

        Get.isRegistered<OneTimeGroomingServiceController>()

            ? Get.find<OneTimeGroomingServiceController>()

            : Get.put(OneTimeGroomingServiceController());

    detailsController =

        Get.isRegistered<GroomingServiceController>()

            ? Get.find<GroomingServiceController>()

            : Get.put(GroomingServiceController());

    _loadInitialData();

  }

    void _togglePackageSelection(
      OneTimeGroomingPackage package,
      int mainServiceId,
    ) {
      setState(() {
        if (_selectedPackages.contains(package)) {
          _selectedPackages.remove(package);
          _packageMainServiceIds.remove(package);
        } else {
          _selectedPackages.add(package);
          _packageMainServiceIds[package] = mainServiceId;
        }
      });
    }

    Future<void> _loadInitialData() async {

      if (categoryController.services.isEmpty) {

        await categoryController.fetchServices();

      }

      if (!mounted || categoryController.services.isEmpty) return;

      _sectionKeys.clear();

      for (final category in categoryController.services) {

        _sectionKeys[category.id] = GlobalKey();

      }

      setState(() {

        _isLoadingAllDetails = true;

      });

      _allServiceDetails.clear();

      for (final category in categoryController.services) {

        await detailsController.fetchServiceDetails(category.id);

        final result = detailsController.service.value;

        if (result != null && result.id == category.id) {

          _allServiceDetails[category.id] = result;

        }

      }


      // Restore existing package selections in edit mode.
        _selectedPackages.clear();
        _packageMainServiceIds.clear();

        if (widget.isEditMode) {
          final existingIds = widget.existingPackageIds.toSet();

          debugPrint(
            'EDIT cart item ID: ${widget.editCartItemId}',
          );
          debugPrint(
            'EDIT package IDs received: $existingIds',
          );


          for (final service in _allServiceDetails.values) {
            for (final package in service.oneTimePackages) {
              debugPrint(
                'Available package: ${package.name}, ID: ${package.id}',
              );
              if (existingIds.contains(package.id)) {
                _selectedPackages.add(package);
                _packageMainServiceIds[package] = package.mainService;
              }
            }
          }
          debugPrint(
            'EDIT restored package IDs: '
            '${_selectedPackages.map((p) => p.id).toList()}',
          );
        }

        debugPrint(
          'Edit cart item ID: ${widget.editCartItemId}',
        );
        debugPrint(
          'Existing package IDs: ${widget.existingPackageIds}',
        );
        debugPrint(
          'Restored package IDs: ' '${_selectedPackages.map((p) => p.id).toList()}',
        );


      if (!mounted) return;

      setState(() {

        _isLoadingAllDetails = false;

      });

    }

    void _scrollToService(int serviceId, int index) {

      setState(() {

        selectedTab = index;

      });

      debugPrint(

        'Tapped service ID: $serviceId, index: $index',

      );

      WidgetsBinding.instance.addPostFrameCallback((_) {

        if (!mounted) return;

        final targetContext = _sectionKeys[serviceId]?.currentContext;

        if (targetContext == null) {

          debugPrint(

            'Section not found for service ID: $serviceId',

          );

          return;

        }

        Scrollable.ensureVisible(

          targetContext,

          duration: const Duration(milliseconds: 500),

          curve: Curves.easeInOut,

          alignment: 0.0,

        );

      });

    }

  // Future<void> _selectCategory(

  //   OneTimeGroomingServiceModel category,

  //   int index,

  // ) async {

  //   if (selectedTab == index &&

  //       detailsController.service.value?.id == category.id) {

  //     return;

  //   }

  //   setState(() {

  //     selectedTab = index;

  //   });

  //   await detailsController.fetchServiceDetails(category.id);

  // }

  @override

  void dispose() {

    _scrollController.dispose();

    super.dispose();

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: PreferredSize(

        preferredSize: const Size.fromHeight(70),

        child: AppBar(

          backgroundColor: Colors.transparent,

          elevation: 0,

          centerTitle: true,

          title: Text(

            'One Time Service',

            style: TextStyle(

              color: Colours.brownColour,

              fontSize: 18,

              fontWeight: FontWeight.w600,

            ),

          ),

          flexibleSpace: ClipRect(

            child: Align(

              alignment: Alignment.topLeft,

              child: SizedBox(

                width: 250,

                height: 100,

                child: Image.network(

                  'https://app.pawdli.com/media/static/topimage.png',

                  fit: BoxFit.cover,

                  errorBuilder: (_, __, ___) =>

                      const SizedBox.shrink(),

                ),

              ),

            ),

          ),

        ),

      ),

      bottomNavigationBar: _selectedPackages.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                  onPressed: () {
                    if (_selectedPackages.isEmpty) return;

                    final selectedServices = _selectedPackages.map((package) {
                      return <String, dynamic>{
                        'main_service_id': package.mainService,
                        'service_id': package.mainService,
                        'one_time_package_id': package.id,
                        'serviceName': package.name,
                        'totalPrice': double.tryParse(package.price)?.round() ?? 0,
                        'selectedSession': 1,
                        'selectedDuration': 1,
                        'totalSessions': 1,
                      };
                    }).toList();

                    final totalPrice = selectedServices.fold<int>(
                      0,
                      (total, service) =>
                          total + (service['totalPrice'] as int),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroomingAddDetailsPage(
                          serviceName: selectedServices
                              .map((service) => service['serviceName'] as String)
                              .join(', '),
                          selectedSession: 1,
                          selectedDuration: 1,
                          totalSessions: selectedServices.length,
                          totalPrice: totalPrice,
                          selectedPet: '',
                          selectedServices: selectedServices,
                          existingCartItem: widget.existingCartItem,
                          existingCartItems: widget.existingCartItems,
                          editCartItemId: widget.editCartItemId,
                          existingPackageIds: widget.existingPackageIds,
                        ),
                      ),
                    );
                  },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colours.primarycolour,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      body: Stack(

        children: [

          Obx(() {

            final categories = categoryController.services;

        if (categoryController.isLoading.value &&

            categories.isEmpty) {

          return Center(

            child: CircularProgressIndicator(

              color: Colours.primarycolour,

            ),

          );

        }

        if (categories.isEmpty) {

          return _buildMessage(

            categoryController.errorMessage.value.isNotEmpty

                ? categoryController.errorMessage.value

                : 'No grooming categories available.',

            onRetry: _loadInitialData,

          );

        }

        return Column(

          children: [
          // Fixed service tabs.
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 5,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = selectedTab == index;

                return GestureDetector(
                  onTap: () => _scrollToService(
                    category.id,
                    index,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colours.primarycolour
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colours.brownColour,
                        width: 0.8,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _tabName(category.name),
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
            // All categories and their subservices in one scrollable page.

            Expanded(

              child: _isLoadingAllDetails &&

                      _allServiceDetails.isEmpty

                  ? Center(

                      child: CircularProgressIndicator(

                        color: Colours.primarycolour,

                      ),

                    )

                  : RefreshIndicator(

                      onRefresh: _loadInitialData,

                      child: SingleChildScrollView(

                        controller: _scrollController,

                        physics: const AlwaysScrollableScrollPhysics(),

                        padding: const EdgeInsets.fromLTRB(

                          16,

                          12,

                          16,

                          24,

                        ),

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                          for (int i = 0;

                              i < categories.length;

                              i++) ...[

                            Builder(

                              builder: (context) {

                                final category = categories[i];

                                final detail =

                                    _allServiceDetails[category.id];

                                return Column(

                                  key: _sectionKeys[category.id],

                                  crossAxisAlignment:

                                      CrossAxisAlignment.start,

                                  children: [

                                    // Service heading.

                                    Text(

                                      category.name,

                                      style: const TextStyle(

                                        fontSize: 21,

                                        fontWeight: FontWeight.bold,

                                        color: Color(0xFF242127),

                                      ),

                                    ),

                                    if (detail != null &&

                                        detail.description

                                            .trim()

                                            .isNotEmpty) ...[

                                      const SizedBox(height: 6),

                                      Text(

                                        detail.description,

                                        style: TextStyle(

                                          fontSize: 14,

                                          height: 1.4,

                                          color: Colors.grey.shade700,

                                        ),

                                      ),

                                    ],

                                    const SizedBox(height: 14),

                                    if (detail == null)

                                      const Padding(

                                        padding: EdgeInsets.all(16),

                                        child: Text(

                                          'Unable to load this service.',

                                        ),

                                      )

                                    else if (detail.oneTimePackages.isEmpty)

                                      const Padding(

                                        padding: EdgeInsets.only(

                                          bottom: 18,

                                        ),

                                        child: Text(

                                          'No subservices available.',

                                        ),

                                      )

                                    else

                                      ...detail.oneTimePackages.map(
                                        (package) => _buildPackageCard(
                                          package,
                                          category.id,
                                        ),
                                      ),

                                    const SizedBox(height: 12),

                                  ],

                                );

                              },

                            ),

                          ],

                        ],

                        ),

                      ),

                    ),

            ),

          ],

        );

      }),

    ],

  ),

);

}

  String _tabName(String name) {

    // Keep the shorter labels shown in your reference UI.

    if (name.toLowerCase() == 'packages') return 'Package';

    if (name.toLowerCase() == 'cleaning services') return 'Clean';

    if (name.toLowerCase() == 'Spa services') return 'Spa';

    return name;

  }

  
    Widget _buildPackageCard(OneTimeGroomingPackage package, int mainServiceId,) {
      final description = package.description.trim();
      final bool isSelected = _selectedPackages.contains(package);

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colours.brownColour,
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    package.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  package.formattedPrice,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: Colors.grey.shade700,
                ),
              ),
            ],

            const SizedBox(height: 8),

            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Get.to(
                      () => GroomingServiceDetailsPage(
                        title: package.name,
                        price: package.formattedPrice,
                        description: description,
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colours.brownColour,
                    ),
                  ),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: () => _togglePackageSelection(package, mainServiceId),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(60, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: isSelected
                        ? Colours.primarycolour
                        : Colors.white,
                    foregroundColor: isSelected
                        ? Colors.white
                        : Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: Colours.primarycolour,
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Text(
                    isSelected ? 'Added' : 'Add',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }


  Widget _buildMessage(

    String message, {

    required VoidCallback onRetry,

  }) {

    return Center(

      child: Padding(

        padding: const EdgeInsets.all(24),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Text(

              message,

              textAlign: TextAlign.center,

            ),

            const SizedBox(height: 14),

            ElevatedButton(

              onPressed: onRetry,

              child: const Text('Retry'),

            ),

          ],

        ),

      ),

    );

  }

}
