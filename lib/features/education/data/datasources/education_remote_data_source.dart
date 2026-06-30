import 'package:cloud_firestore/cloud_firestore.dart';

class EducationRemoteDataSource {
  final FirebaseFirestore _firestore;

  EducationRemoteDataSource({FirebaseFirestore? firestoreInstance})
      : _firestore = firestoreInstance ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getArticles() async {
    final snapshot = await _firestore.collection('articles').orderBy('publishedAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<Map<String, dynamic>?> getArticle(String id) async {
    final doc = await _firestore.collection('articles').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }

  Future<List<Map<String, dynamic>>> getQuizzes() async {
    final snapshot = await _firestore.collection('quizzes').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<Map<String, dynamic>?> getQuiz(String id) async {
    final doc = await _firestore.collection('quizzes').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return data;
  }

  Future<void> markArticleRead(String uid, String articleId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('completedContent')
        .doc(articleId)
        .set({'type': 'article', 'completedAt': FieldValue.serverTimestamp()});
  }

  Future<void> saveQuizResult(String uid, String quizId, int score, int total) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('completedContent')
        .doc(quizId)
        .set({'type': 'quiz', 'score': score, 'total': total, 'completedAt': FieldValue.serverTimestamp()});
  }

  Future<void> awardPoints(String uid, int points) async {
    await _firestore.collection('users').doc(uid).update({
      'points': FieldValue.increment(points),
    });
  }

  Future<List<String>> getCompletedContentIds(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('completedContent')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  static List<Map<String, dynamic>> defaultArticles() {
    return [
      {
        'id': 'waste_separation',
        'title': 'Waste Separation 101',
        'summary': 'Learn how to properly separate your waste into recyclables, organics, and landfill.',
        'content': '''Proper waste separation is the foundation of effective recycling and waste management. By separating your waste correctly, you help ensure that materials can be properly processed and given a second life.

## Why Separate Waste?

When waste is mixed together, recyclable materials become contaminated and often end up in landfills. Separating waste at the source is the most effective way to ensure high-quality recycling.

## The Three Main Categories

### 1. Recyclables
These include paper, cardboard, glass, metals, and certain plastics. Always rinse containers before recycling to avoid contamination.

### 2. Organic Waste
Food scraps, yard trimmings, and other biodegradable materials can be composted to create nutrient-rich soil rather than producing methane in landfills.

### 3. Landfill Waste
Items that cannot be recycled or composted should go to landfill. This includes certain plastics, diapers, and hazardous materials that require special handling.

## Tips for Success
- Keep separate bins in your kitchen for different waste types
- Learn your local recycling guidelines as they can vary
- When in doubt, check the packaging for recycling symbols
- Never put recyclables in plastic bags - keep them loose''',
        'category': 'Recycling',
        'imageUrl': '',
        'readTimeMinutes': 4,
        'publishedAt': DateTime(2026, 6, 1),
      },
      {
        'id': 'plastic_pollution',
        'title': 'The Truth About Plastic Pollution',
        'summary': 'Understanding the impact of plastic on our oceans and what you can do to help.',
        'content': '''Plastic pollution is one of the most pressing environmental challenges of our time. Every year, millions of tons of plastic waste enter our oceans, harming marine life and ecosystems.

## The Scale of the Problem

Over 8 million tons of plastic enter the ocean each year. That's equivalent to dumping a garbage truck full of plastic into the ocean every minute. By 2050, there could be more plastic than fish in the sea by weight.

## How Plastic Affects Marine Life

Marine animals often mistake plastic for food. Sea turtles confuse plastic bags for jellyfish, fish ingest microplastics, and seabirds feed plastic to their chicks. This leads to starvation, poisoning, and death.

## What You Can Do

### Reduce Single-Use Plastics
Carry a reusable water bottle, bring your own shopping bags, and avoid products with excessive plastic packaging.

### Proper Disposal
Always dispose of plastic waste properly and recycle when possible. Every piece of plastic that stays out of the ocean makes a difference.

### Participate in Cleanups
Join local beach or river cleanups to remove plastic waste before it reaches the ocean. Even small actions add up when done collectively.

### Spread Awareness
Share what you've learned with friends and family. Awareness is the first step toward change.''',
        'category': 'Environment',
        'imageUrl': '',
        'readTimeMinutes': 5,
        'publishedAt': DateTime(2026, 5, 15),
      },
      {
        'id': 'composting_guide',
        'title': 'Composting at Home: A Beginner\'s Guide',
        'summary': 'Turn your kitchen scraps into nutrient-rich soil with this simple guide.',
        'content': '''Composting is nature's way of recycling. By creating a compost system at home, you can transform your kitchen scraps and yard waste into valuable fertilizer for your garden.

## Why Compost?

Composting reduces methane emissions from landfills, produces free fertilizer, improves soil health, and helps your plants thrive. It's one of the most impactful actions you can take as an individual.

## What to Compost

### Greens (Nitrogen-rich)
- Fruit and vegetable scraps
- Coffee grounds and filters
- Fresh grass clippings
- Plant trimmings

### Browns (Carbon-rich)
- Dry leaves and straw
- Paper and cardboard (shredded)
- Wood chips and sawdust
- Eggshells (crushed)

## What NOT to Compost
- Meat, fish, and dairy products
- Oily or greasy foods
- Diseased plants
- Pet waste
- Weeds that have gone to seed

## Getting Started

Choose a location for your compost pile or bin. Layer browns and greens in roughly a 3:1 ratio. Keep the pile moist but not wet, and turn it regularly for aeration. In 3-6 months, you'll have rich, dark compost ready to use.''',
        'category': 'Lifestyle',
        'imageUrl': '',
        'readTimeMinutes': 4,
        'publishedAt': DateTime(2026, 4, 20),
      },
    ];
  }

  static List<Map<String, dynamic>> defaultQuizzes() {
    return [
      {
        'id': 'recycling_basics',
        'title': 'Recycling Basics',
        'description': 'Test your knowledge of recycling fundamentals.',
        'category': 'Recycling',
        'rewardPoints': 15,
        'passingScore': 60,
        'questions': [
          {
            'question': 'Which of these items can typically be recycled?',
            'options': ['Plastic grocery bags', 'Glass bottles', 'Pizza boxes with grease', 'Styrofoam'],
            'correctIndex': 1,
          },
          {
            'question': 'What does the number inside the recycling triangle indicate?',
            'options': ['The color of the plastic', 'The type of plastic resin', 'How many times it can be recycled', 'The size of the container'],
            'correctIndex': 1,
          },
          {
            'question': 'Why should you rinse containers before recycling?',
            'options': ['To make them lighter', 'To prevent contamination', 'To remove the label', 'It is not necessary'],
            'correctIndex': 1,
          },
          {
            'question': 'What percentage of plastic waste is actually recycled globally?',
            'options': ['About 50%', 'About 30%', 'About 9%', 'About 75%'],
            'correctIndex': 2,
          },
          {
            'question': 'Which material takes the longest to decompose in a landfill?',
            'options': ['Paper', 'Cotton fabric', 'Glass', 'Orange peels'],
            'correctIndex': 2,
          },
        ],
      },
      {
        'id': 'ocean_conservation',
        'title': 'Ocean Conservation',
        'description': 'How much do you know about protecting our oceans?',
        'category': 'Environment',
        'rewardPoints': 20,
        'passingScore': 60,
        'questions': [
          {
            'question': 'What is the largest source of ocean plastic pollution?',
            'options': ['Fishing nets', 'Land-based sources', 'Cruise ships', 'Offshore drilling'],
            'correctIndex': 1,
          },
          {
            'question': 'How long does it take for a plastic bottle to decompose in the ocean?',
            'options': ['50 years', '100 years', '450 years', '10 years'],
            'correctIndex': 2,
          },
          {
            'question': 'What is a "dead zone" in the ocean?',
            'options': ['An area with no waves', 'An area with low oxygen', 'A deep trench', 'A coral reef'],
            'correctIndex': 1,
          },
          {
            'question': 'Which of these helps reduce ocean acidification?',
            'options': ['Adding lime to seawater', 'Reducing CO2 emissions', 'Building sea walls', 'Dumping nutrients'],
            'correctIndex': 1,
          },
        ],
      },
    ];
  }
}
