import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:random_cat_facts/screens/home/home_cubit.dart';
import 'package:random_cat_facts/utils/build_image.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isFactSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return Stack(
            children: [
              if (state is HomeLoaded) _buildBackgroundWithBlur(context, state),
              _buildOverlay(),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 8.h),
                      Expanded(child: _buildContentCard(context, state)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleStateChanges(BuildContext context, HomeState state) {
    if (state is FactAlreadySaved) {
      _showSnackBar(
        context,
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.orange,
        backgroundColor: Colors.orange.shade50,
        message: 'This fact is already saved in your collection',
      );
    }
    if (state is FactSaved) {
      setState(() => _isFactSaved = true);
      _showSnackBar(
        context,
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
        backgroundColor: Colors.green.shade50,
        message: 'Fact saved successfully!',
      );
    }
    if (state is HomeLoading) {
      // Reset save state when generating a new fact
      setState(() => _isFactSaved = false);
    }
    if (state is HomeLoaded && !_isFactSaved) {
      // Keep _isFactSaved as true if it was already saved
      // This prevents resetting when HomeLoaded is emitted after FactSaved
    }
  }

  void _showSnackBar(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Cat Dose',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Learn interesting facts about cats',
          style: TextStyle(fontSize: 16.sp, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildBackgroundWithBlur(BuildContext context, HomeLoaded state) {
    return SoftEdgeBlur(
      edges: [
        EdgeBlur(
          type: EdgeType.bottomEdge,
          size: MediaQuery.of(context).size.height,
          sigma: 40,
          tintColor: Colors.black.withValues(alpha: 0.2),
          controlPoints: [
            ControlPoint(position: 1, type: ControlPointType.visible),
          ],
        ),
      ],
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: _buildImage(context, state),
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(color: Colors.black.withValues(alpha: 0.4)),
    );
  }

  Widget _buildContentCard(BuildContext context, HomeState state) {
    return Card(
      elevation: 4,
      color: Colors.white.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Did you know?',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            _buildFactContainer(state),
            SizedBox(height: 6.h),
            if (state is HomeLoaded) _buildCatImage(context, state),
            SizedBox(height: 20.h),
            _buildActionButtons(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildFactContainer(HomeState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: _buildFactContent(state),
    );
  }

  Widget _buildFactContent(HomeState state) {
    if (state is HomeLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is HomeError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: ${state.message}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          const Text(
            'Please try again',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    } else if (state is HomeLoaded) {
      return SingleChildScrollView(
        child: AutoSizeText(
          state.catData.fact,
          maxLines: 6,
          minFontSize: 14,
          style: TextStyle(fontSize: 18.sp, height: 1.5),
        ),
      );
    }

    return Text(
      'Tap the button below to get a random cat fact!',
      style: TextStyle(fontSize: 18.sp, height: 1.5, color: Colors.grey),
    );
  }

  Widget _buildCatImage(BuildContext context, HomeLoaded state) {
    return Flexible(
      flex: 2,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: _buildImage(context, state),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, HomeLoaded state) {
    final cubit = context.read<HomeCubit>();
    final cachedPath = cubit.currentCachedImagePath;

    if (cachedPath != null) {
      final file = File(cachedPath);
      if (file.existsSync()) {
        return buildImage(cachedPath, fit: BoxFit.cover);
      }
    }

    if (state.catData.imageUrl.isNotEmpty) {
      return buildImage(state.catData.imageUrl, fit: BoxFit.cover);
    }

    return Container(color: Colors.grey[200]);
  }

  Widget _buildActionButtons(BuildContext context, HomeState state) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (state is HomeLoaded) _buildSaveButton(context, state),
          _buildGenerateButton(context, state),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, HomeLoaded state) {
    return GestureDetector(
      onTap: _isFactSaved ? null : () => context.read<HomeCubit>().saveCatFact(state.catData),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _isFactSaved ? Colors.green[400] : Colors.green[200],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(
          _isFactSaved ? Icons.check_circle : Icons.save,
          color: _isFactSaved ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context, HomeState state) {
    final isLoading = state is HomeLoading;
    return GestureDetector(
      onTap: isLoading ? null : () => context.read<HomeCubit>().loadRandomCatData(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.pink[100],
        ),
        child: Text(
          isLoading ? 'Loading...' : 'Generate Random Fact',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
