import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DeviceSummaryShimmer extends StatelessWidget {
  const DeviceSummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerTitle("Resumen rápido"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(4, (_) => _shimmerStatCard()),
          ),
          const SizedBox(height: 24),
          _shimmerSection(context),
          const SizedBox(height: 24),
          _shimmerSection(context),
          const SizedBox(height: 24),
          _shimmerSection(context),
        ],
      ),
    );
  }

  Widget _shimmerTitle(String title) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 180,
        height: 24,
        color: Colors.white,
      ),
    );
  }

  Widget _shimmerStatCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 140,
          height: 80,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 60, height: 12, color: Colors.white),
              const SizedBox(height: 10),
              Container(width: 100, height: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerSection(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Container(
          width: double.infinity,
          height: 240,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(width: 24, height: 24, color: Colors.white),
                  const SizedBox(width: 8),
                  Container(width: 120, height: 16, color: Colors.white),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(width: double.infinity, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
