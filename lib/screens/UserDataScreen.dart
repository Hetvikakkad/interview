import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/userProvider.dart';

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({super.key});

  @override
  State<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchPosts();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter API Provider Example'),
      ),

      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          // Loading
          if (provider.isLoading && provider.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Empty
          if (provider.posts.isEmpty) {
            return const Center(
              child: Text('No posts found.'),
            );
          }

          // List
          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchPosts();
            },
            child: ListView.builder(
              itemCount: provider.posts.length,
              itemBuilder: (context, index) {
                final post = provider.posts[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      post.title ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      post.body ?? '',
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // EDIT
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            _showForm(
                              post.id?.toInt() ?? 0,
                              post.title ?? '',
                              post.body ?? '',
                            );
                          },
                        ),

                        // DELETE
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final id = post.id?.toInt() ?? 0;

                            await provider.deletePost(id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(

        onPressed: () {
            _showForm(0,'','');
          },

        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  // ============================================================
  // SHOW UPDATE FORM
  // ============================================================

  void _showForm(
      int? id,
      String title,
      String description,
      ) {
    if (id != null || id != 0) {
      titleController.text = title;
      descriptionController.text = description;
    } else {
      titleController.clear();
      descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,

      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom:
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TITLE
                TextField(
                  controller: titleController,
                  keyboardType: TextInputType.text,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                // DESCRIPTION
                TextField(
                  controller: descriptionController,
                  keyboardType: TextInputType.text,
                  minLines: 5,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // UPDATE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validation
                      if (titleController.text.trim().isEmpty ||
                          descriptionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please fill all fields',
                            ),
                          ),
                        );

                        return;
                      }

                      final provider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );

                      // UPDATE
                      if (id != null) {
                        await provider.updatePut(
                          id,
                          titleController.text.trim(),
                          descriptionController.text.trim(),
                        );
                      }
                      else{
                        await provider.updatePost(
                          0,
                          titleController.text.trim(),
                          descriptionController.text.trim(),
                        );
                      }

                      // Clear
                      titleController.clear();
                      descriptionController.clear();

                      // Close bottom sheet
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },

                    child: const Text(
                      'Update Data',
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