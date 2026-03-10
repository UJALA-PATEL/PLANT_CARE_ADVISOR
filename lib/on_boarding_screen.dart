import 'package:flutter/material.dart';
import 'package:sejjjjj/dashboard.dart';

// Onboarding data model
class OnboardingData {
  final String title;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}

// Onboarding data list
final List<OnboardingData> onboardingData = [
  OnboardingData(
    title: 'Know more about your plant.',
    description:
    'Identify plant disease instantly using AI-powered diagnosis. Just snap a picture!',
    image: 'assets/images/plant_scanner.png',
  ),
  OnboardingData(
    title: 'See How Plants Look at different places',
    description:
    'See how your plants will look and grow using our augmented reality guide.',
    image: 'assets/images/augmentedreality.png',
  ),
  OnboardingData(
    title: 'Smart Reminder and Insights',
    description:
    'Never miss a care task with personalized reminders and health insights.',
    image: 'assets/images/reminder.png',
  ),
  OnboardingData(
    title: 'Community and Sharing',
    description:
    'Join a community of plant lovers. Share, learn, and connect.',
    image: 'assets/images/community.png',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Next page action
  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // If last page, navigate to SignUpScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }


  // Skip action
  void _skip() {
    // Navigate directly to LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      body: Column(
        children: [
          // Title bar
          Container(
            color: Colors.green,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: const Text(
              "Plant Care",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image
                      Image.asset(
                        onboardingData[index].image,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 30),
                      // Title
                      Text(
                        onboardingData[index].title,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Description
                      Text(
                        onboardingData[index].description,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Bottom Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _skip,
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Row(
                  children: List.generate(
                    onboardingData.length,
                        (dotIndex) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == dotIndex
                            ? Colors.green
                            : Colors.green.shade200,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    _currentPage == onboardingData.length - 1
                        ? "Finish"
                        : "Next",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
