import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:random_cat_facts/model/cat_fact_model.dart';
import 'package:random_cat_facts/screens/favorite/favorite_cubit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:random_cat_facts/utils/build_image.dart';
import 'package:share_plus/share_plus.dart';

class FavoriteFactsPage extends StatefulWidget {
  const FavoriteFactsPage({super.key});

  @override
  State<FavoriteFactsPage> createState() => _FavoriteFactsPageState();
}

class _FavoriteFactsPageState extends State<FavoriteFactsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoriteFactsCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved Cat Facts'),
        ),
        body: BlocBuilder<FavoriteFactsCubit, FavoriteFactsState>(
          builder: (context, state) {
            if (state is SavedFactsInitial || state is SavedFactsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is SavedFactsLoaded) {
              return _buildGrid(context, state.facts);
            } else if (state is SavedFactsEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 60.w,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "You haven't saved any cat facts yet.",
                      style: TextStyle(fontSize: 18.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Go back and save some interesting facts!",
                      style: TextStyle(fontSize: 16.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (state is SavedFactsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60.w,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Error: ${state.message}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FavoriteFactsCubit>().loadSavedFacts();
                      },
                      child: const Text("Try Again"),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<CatFactModel> facts) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16.w,
        crossAxisSpacing: 16.w,
        itemCount: facts.length,
        itemBuilder: (context, index) {
          final fact = facts[index];
          return _buildGridItem(context, fact);
        },
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, CatFactModel fact) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          _showFactDetails(context, fact);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  child: buildImage(fact.imageUrl, fit: BoxFit.cover),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.r),
              child: Text(
                fact.fact,
                style: TextStyle(
                  fontSize: 12.sp,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.r, bottom: 8.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(context, fact);
                    },
                    iconSize: 20.r,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFactDetails(BuildContext context, CatFactModel fact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    margin: EdgeInsets.only(bottom: 20.h),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 24.sp,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Cat Facts",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: buildImage(fact.imageUrl, fit: BoxFit.cover),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Saved on: ${_formatDate(fact.savedAt)}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                    InkWell(
                      onTap: () => _shareFact(context, fact),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Share",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  fact.fact,
                  style: TextStyle(
                    fontSize: 16.sp,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareFact(BuildContext context, CatFactModel fact) async {
    try {
      final String shareText = """
🐱 Did you know?

${fact.fact}

♥️ Shared from the Daily Cat Dose - Learn fascinating facts about cats every day!
""";

      final imageFile = File(fact.imageUrl);

      if (imageFile.existsSync()) {
        // Share with local file
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: shareText,
        );
      } else {
        // Fallback to text only
        await Share.share(shareText);
      }
    } catch (e) {
      log('Error sharing: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Fallback to text-only share
      try {
        await Share.share("""
🐱 Did you know?

${fact.fact}

♥️ Shared from the Daily Cat Dose - Learn fascinating facts about cats every day!
""");
      } catch (e) {
        log('Failed to share even text: $e');
      }
    }
  }

  void _confirmDelete(BuildContext context, CatFactModel fact) {
    final cubit = context.read<FavoriteFactsCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Fact"),
        content: const Text("Are you sure you want to delete this cat fact?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Delete the image file if it exists
              try {
                final imageFile = File(fact.imageUrl);
                if (await imageFile.exists()) {
                  await imageFile.delete();
                }
              } catch (e) {
                log('Error deleting image file: $e');
              }

              cubit.deleteFact(fact.id!);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    final dateTime = DateTime.parse(isoString);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
