// lib/modules/search/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../provider/search_provider.dart';
import 'category_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();


  @override
  void initState() {
    // TODO: implement initState
    _searchController.addListener(() {
      setState(() {}); // refresh suffixIcon visibility
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  void _collapseResults(BuildContext context) {
    FocusScope.of(context).unfocus();
    final provider = context.read<SearchProvider>();
    provider.clearResults();
    provider.clearError(); // <-- add a clearError method in provider
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _collapseResults(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          title: const Text('Discover Plants ', style: TextStyle(color: Colors.white),),
          elevation: 4,
          shadowColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.025),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("Categories", style: AppTextStyles.headlineLarge,),
                  ),
                  Expanded(child: _buildCategoryGrid(context, screenWidth)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  /// 🌿 Category grid (responsive)
  Widget _buildCategoryGrid(BuildContext context, double screenWidth) {
    final categories = [
      {"name": "Trees", "image": "assets/categories/trees.jpg"},
      {"name": "Flowers", "image": "assets/categories/flowers.jpg"},
      {"name": "Herbs", "image": "assets/categories/herbs.jpg"},
      {"name": "Succulents", "image": "assets/categories/succulent.jpg"},
      {"name": "Indoor Plants", "image": "assets/categories/indoor.jpg"},
      {"name": "Cactus", "image": "assets/categories/cactus.jpg"},
    ];

    final crossAxisCount = screenWidth < 400 ? 2 : 3;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: screenWidth * 0.04,
        mainAxisSpacing: screenWidth * 0.04,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: context.read<SearchProvider>(),
                  child: CategoryScreen(category: category["name"]!),
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.backgroundWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.asset(
                      category["image"]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Text(
                    category["name"]!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
