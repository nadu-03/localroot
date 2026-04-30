import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/color_resources.dart';

class ViewListingView extends StatefulWidget {
  const ViewListingView({super.key});

  @override
  State<ViewListingView> createState() => _ViewListingViewState();
}

class _ViewListingViewState extends State<ViewListingView> {
  int selectedTabIndex = 0;

  final List<_ListingItem> soldItems = const [
    _ListingItem(
      imagePath: 'assets/images/clothe_1.png',
      title: 'Blue Checked Blouse',
      category: 'Clothes',
      price: '950 LKR',
    ),
    _ListingItem(
      imagePath: 'assets/images/clothe_2.png',
      title: 'Red ballet shoes',
      category: 'Clothes',
      price: '1500 LKR',
    ),
    _ListingItem(
      imagePath: 'assets/images/books.png',
      title: 'Motivational Book',
      category: 'Books',
      price: '870 LKR',
    ),
    _ListingItem(
      imagePath: 'assets/images/furniture.png',
      title: 'Miniature Wooden Decor',
      category: 'Decos',
      price: '1600 LKR',
    ),
  ];

  final List<_ListingItem> unsoldItems = const [
    _ListingItem(
      imagePath: 'assets/images/clothe_2.png',
      title: 'Printed Skirt',
      category: 'Clothes',
      price: '790 LKR',
    ),
    _ListingItem(
      imagePath: 'assets/images/decos.png',
      title: 'Wall Frame',
      category: 'Decos',
      price: '1250 LKR',
    ),
    _ListingItem(
      imagePath: 'assets/images/books.png',
      title: 'Novel Collection',
      category: 'Books',
      price: '560 LKR',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = selectedTabIndex == 0 ? soldItems : unsoldItems;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Listing',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'sold',
                      selected: selectedTabIndex == 0,
                      onTap: () => setState(() => selectedTabIndex = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TabButton(
                      label: 'unsold',
                      selected: selectedTabIndex == 1,
                      onTap: () => setState(() => selectedTabIndex = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFD6D6D6)),
                            image: DecorationImage(
                              image: AssetImage(item.imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.category,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: const Color(0xFF6F6F6F)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.price,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? ColorResources.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD2D2D2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              offset: Offset(0, 1),
              blurRadius: 1,
            ),
          ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ListingItem {
  final String imagePath;
  final String title;
  final String category;
  final String price;

  const _ListingItem({
    required this.imagePath,
    required this.title,
    required this.category,
    required this.price,
  });
}
