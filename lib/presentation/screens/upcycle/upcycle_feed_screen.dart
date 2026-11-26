import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../state/upcycle_provider.dart';
import 'create_upcycle_screen.dart';
import 'upcycle_detail_screen.dart';

class UpcycleFeedScreen extends StatefulWidget {
  const UpcycleFeedScreen({super.key});

  @override
  State<UpcycleFeedScreen> createState() => _UpcycleFeedScreenState();
}

class _UpcycleFeedScreenState extends State<UpcycleFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UpcycleProvider>().fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final upcycleProv = context.watch<UpcycleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inspirasi & Daur Ulang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.upcycleColor),
            tooltip: 'Tulis Panduan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateUpcycleScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => upcycleProv.fetchPosts(),
        color: AppColors.upcycleColor,
        child: upcycleProv.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.upcycleColor))
            : upcycleProv.posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 64, color: AppColors.upcycleColor),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada ide upcycle',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Bagikan ide kreatif pemanfaatan barang bekas pertama Anda!',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateUpcycleScreen()),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Buat Panduan DIY'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.upcycleColor),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: upcycleProv.posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final post = upcycleProv.posts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UpcycleDetailScreen(post: post),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (post.coverImageUrl.isNotEmpty)
                                AspectRatio(
                                  aspectRatio: 1.8,
                                  child: CachedNetworkImage(
                                    imageUrl: post.coverImageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: Colors.grey[200]),
                                    errorWidget: (_, __, ___) => Container(
                                      color: const Color(0xFFF3E5F5),
                                      child: const Icon(Icons.lightbulb, color: AppColors.upcycleColor),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      post.contentMaterials,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: AppColors.upcycleColor.withOpacity(0.15),
                                          child: Text(
                                            post.author != null && post.author!.fullName.isNotEmpty
                                                ? post.author!.fullName[0]
                                                : 'A',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.upcycleColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          post.author?.fullName ?? 'Kreator Sirkular',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: Icon(
                                            post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                                            color: post.isLikedByMe ? Colors.red : AppColors.textMuted,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            upcycleProv.toggleLike(post.id, post.isLikedByMe);
                                          },
                                        ),
                                        Text(
                                          '${post.likesCount}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
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
    );
  }
}
