import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sejjjjj/Community/expert_q_A.dart';
import 'package:sejjjjj/Community/forum_screen.dart';
import 'package:sejjjjj/Community/live_session_Screen.dart';
import 'package:sejjjjj/profile_page.dart';
import 'ai_diagnosis_screen.dart';
import 'package:sejjjjj/Community/Services/firebase_services.dart';
import 'package:video_player/video_player.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  CommunityScreenState createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ForumScreen(),
    const DiagnosisScreen(),
    const ExpertQNAScreen(),
    const LiveSessionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plant Community',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ✅ Search Bar, Profile, & Reminder - Sirf Home Screen Pe Dikhao
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Search Field (Only on Home Page)
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.green),
                        ),
                        onTap: () {
                          showSearch(context: context, delegate: PostSearch());
                        },
                      ),
                    ),

                    // Reminder Icon (Only on Home Page)
                    IconButton(
                      icon: const Icon(
                          Icons.notifications, size: 28, color: Colors.green),
                      onPressed: () {
                        // Reminder Functionality
                      },
                    ),

                    // Profile Icon (Only on Home Page)
                    IconButton(
                      icon: const Icon(
                          Icons.account_circle, size: 28, color: Colors.green),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (
                              context) => const UserProfileScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          // 🌿 Show Selected Page
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),

      // 🌍 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Diagnosis'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Expert Q&A'),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live'),
          // Profile Tab
        ],
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _commentController = TextEditingController();

  void _addComment(String postId) {
    if (_commentController.text.isNotEmpty) {
      FirebaseService.addComment(postId, _commentController.text);
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.getPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final postId = post.id;

              final data = post.data() as Map<String, dynamic>? ?? {};
              final postTitle = data['text'] ?? "No Title";
              final imageUrl = data['mediaUrl'] ?? "";
              final likes = data['likes'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                          },
                        ),

                      ListTile(
                        title: Text(
                          postTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.thumb_up, color: Colors.green),
                              onPressed: () => FirebaseService.likePost(postId),
                            ),
                            Text(likes.toString()),
                          ],
                        ),
                      ),

                      // Comments Section
                      StreamBuilder<List<String>>(
                        stream: FirebaseService.getComments(postId),
                        builder: (context, commentSnapshot) {
                          if (!commentSnapshot.hasData) return const SizedBox();
                          final comments = List<String>.from(commentSnapshot.data ?? []);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: comments.map((comment) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 16, top: 4),
                                child: Text(
                                  "- $comment",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      // Comment Input Field
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: "Add a comment...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.green),
                              onPressed: () => _addComment(postId),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Search Functionality
class PostSearch extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = "")];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text("Please enter something to search."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('text', isGreaterThanOrEqualTo: query)
          .where('text', isLessThanOrEqualTo: '$query\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data!.docs;

        if (results.isEmpty) {
          return const Center(child: Text("No matching posts found."));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final data = results[index].data() as Map<String, dynamic>;
            final postId = results[index].id;
            final title = data['text'] ?? '';
            final imageUrl = data['mediaUrl'] ?? '';
            final likes = data['likes'] ?? 0;

            return Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl.isNotEmpty)
                      Image.network(
                        imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up, color: Colors.green),
                            onPressed: () => FirebaseService.likePost(postId),
                          ),
                          Text(likes.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text("Search for plant names, symptoms, or tips"));
  }
}

/*class PostSearch extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = "")];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text("Search result for: $query"));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(child: Text("Search for posts"));
  }
}*/

// Video Player Widget
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      }).catchError((error) {
        print("Video loading error: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : const Center(child: CircularProgressIndicator()),
        IconButton(
          icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            setState(() {
              _controller.value.isPlaying ? _controller.pause() : _controller.play();
            });
          },
        ),
      ],
    );
  }
}
