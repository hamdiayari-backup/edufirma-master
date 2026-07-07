import 'package:flutter/foundation.dart';
import '../core/services/course_service.dart';
import '../core/services/category_service.dart';
import '../features/courses/data/models/course_model.dart';
import '../features/courses/data/models/category_model.dart';

class CourseProvider extends ChangeNotifier {
  final CourseService _courseService;
  final CategoryService _categoryService;

  // Separate loading states
  bool _isLoadingCourses = false;
  bool _isLoadingFeatured = false;
  bool _isLoadingBundles = false;
  bool _isLoadingCategories = false;
  bool _isLoadingDetails = false;
  bool _isLoadingContent = false;

  List<CourseModel> _courses = [];
  List<CourseModel> _featuredCourses = [];
  List<CourseModel> _bundles = [];
  List<CategoryModel> _categories = [];
  List<CategoryModel> _trendCategories = [];
  Map<String, dynamic>? _selectedCourse;
  List<Map<String, dynamic>> _courseContent = [];
  String? _errorMessage;

  CourseProvider(this._courseService, this._categoryService);

  bool get isLoading =>
      _isLoadingCourses ||
      _isLoadingFeatured ||
      _isLoadingBundles ||
      _isLoadingDetails;
  bool get isLoadingCourses => _isLoadingCourses;
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isLoadingBundles => _isLoadingBundles;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingContent => _isLoadingContent;

  List<CourseModel> get courses => _courses;
  List<CourseModel> get featuredCourses => _featuredCourses;
  List<CourseModel> get bundles => _bundles;
  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get trendCategories => _trendCategories;
  Map<String, dynamic>? get selectedCourse => _selectedCourse;
  List<Map<String, dynamic>> get courseContent => _courseContent;
  String? get errorMessage => _errorMessage;

  /// Fetch all courses
  Future<void> fetchCourses({
    int offset = 0,
    bool upcoming = false,
    bool free = false,
    bool discount = false,
    String? sort,
    String? category,
  }) async {
    _isLoadingCourses = true;
    _errorMessage = null;
    // Clear previous courses when offset is 0 (new filter/search)
    if (offset == 0) {
      _courses = [];
    }
    notifyListeners();

    try {
      debugPrint('=== FETCHING COURSES ===');
      debugPrint('Category filter: $category');
      final result = await _courseService.getAll(
        offset: offset,
        upcoming: upcoming,
        free: free,
        discount: discount,
        sort: sort,
        cat: category,
      );
      debugPrint('Service returned ${result.length} courses');
      if (offset == 0) {
        _courses = result;
      } else {
        _courses.addAll(result);
      }
      if (result.isNotEmpty) {
        debugPrint('First course: ${result.first.title}');
      }
      debugPrint('Loaded ${_courses.length} courses');
    } catch (e, stack) {
      _errorMessage = 'Failed to load courses';
      debugPrint('Error loading courses: $e');
      debugPrint('Stack: $stack');
    }

    _isLoadingCourses = false;
    notifyListeners();
  }

  /// Fetch featured courses
  Future<void> fetchFeaturedCourses({String? category}) async {
    _isLoadingFeatured = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _featuredCourses = await _courseService.featuredCourses(cat: category);
      debugPrint('Loaded ${_featuredCourses.length} featured courses');
    } catch (e) {
      _errorMessage = 'Failed to load featured courses';
      debugPrint('Error loading featured: $e');
    }

    _isLoadingFeatured = false;
    notifyListeners();
  }

  /// Fetch bundles
  Future<void> fetchBundles({int offset = 0, String? category}) async {
    _isLoadingBundles = true;
    _errorMessage = null;
    // Clear previous bundles when offset is 0 (new filter/search)
    if (offset == 0) {
      _bundles = [];
    }
    notifyListeners();

    try {
      debugPrint('=== FETCHING BUNDLES ===');
      debugPrint('Category filter: $category');
      final result = await _courseService.getAll(
        offset: offset,
        bundle: true,
        cat: category,
      );
      debugPrint('Service returned ${result.length} bundles');
      if (offset == 0) {
        _bundles = result;
      } else {
        _bundles.addAll(result);
      }
      debugPrint('Loaded ${_bundles.length} bundles');
    } catch (e) {
      _errorMessage = 'Failed to load bundles';
      debugPrint('Error loading bundles: $e');
    }

    _isLoadingBundles = false;
    notifyListeners();
  }

  /// Fetch courses for a specific category using category endpoint
  Future<void> fetchCategoryCourses(int categoryId, {int offset = 0}) async {
    _isLoadingCourses = true;
    _errorMessage = null;
    // Clear previous courses when offset is 0
    if (offset == 0) {
      _courses = [];
    }
    notifyListeners();

    try {
      debugPrint('=== FETCHING CATEGORY COURSES ===');
      debugPrint('Category ID: $categoryId');
      final result =
          await _categoryService.getCategoryCourses(categoryId, offset: offset);
      debugPrint('Service returned ${result.length} courses');
      if (offset == 0) {
        _courses = result;
      } else {
        _courses.addAll(result);
      }
      if (result.isNotEmpty) {
        debugPrint('First course: ${result.first.title}');
      }
      debugPrint('Loaded ${_courses.length} courses for category');
    } catch (e, stack) {
      _errorMessage = 'Failed to load category courses';
      debugPrint('Error loading category courses: $e');
      debugPrint('Stack: $stack');
    }

    _isLoadingCourses = false;
    notifyListeners();
  }

  /// Fetch courses from multiple categories and merge them
  Future<void> fetchCoursesFromMultipleCategories(List<int> categoryIds) async {
    _isLoadingCourses = true;
    _errorMessage = null;
    _courses = [];
    notifyListeners();

    try {
      debugPrint('=== FETCHING COURSES FROM MULTIPLE CATEGORIES ===');
      debugPrint('Category IDs: $categoryIds');

      List<CourseModel> allCourses = [];

      // Fetch courses from each category
      for (var categoryId in categoryIds) {
        try {
          final result = await _courseService.getAll(
            offset: 0,
            cat: categoryId.toString(),
          );
          debugPrint('Category $categoryId: ${result.length} courses');
          allCourses.addAll(result);
        } catch (e) {
          debugPrint('Error fetching courses for category $categoryId: $e');
        }
      }

      // Remove duplicates based on course ID
      final uniqueCourses = <int, CourseModel>{};
      for (var course in allCourses) {
        if (course.id != null) {
          uniqueCourses[course.id!] = course;
        }
      }

      _courses = uniqueCourses.values.toList();
      debugPrint('Total unique courses loaded: ${_courses.length}');

      if (_courses.isNotEmpty) {
        debugPrint('First course: ${_courses.first.title}');
      }
    } catch (e, stack) {
      _errorMessage = 'Failed to load courses from categories';
      debugPrint('Error loading courses: $e');
      debugPrint('Stack: $stack');
    }

    _isLoadingCourses = false;
    notifyListeners();
  }

  /// Fetch categories
  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
      debugPrint('Loaded ${_categories.length} categories');
    } catch (e) {
      _errorMessage = 'Failed to load categories';
      debugPrint('Error loading categories: $e');
    }

    _isLoadingCategories = false;
    notifyListeners();
  }

  /// Fetch trend categories
  Future<void> fetchTrendCategories() async {
    try {
      _trendCategories = await _categoryService.getTrendCategories();
      debugPrint('Loaded ${_trendCategories.length} trend categories');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load trend categories';
      debugPrint('Error loading trend categories: $e');
      notifyListeners();
    }
  }

  /// Fetch single course details
  Future<void> fetchCourseDetails(int id, {bool isBundle = false}) async {
    _isLoadingDetails = true;
    _errorMessage = null;
    _courseContent = []; // Clear previous content
    notifyListeners();

    try {
      _selectedCourse =
          await _courseService.getSingleCourse(id, isBundle: isBundle);
      debugPrint('Fetched course details for id: $id');
      debugPrint('auth_has_bought: ${_selectedCourse?['auth_has_bought']}');
      debugPrint('price: ${_selectedCourse?['price']}');

      // Automatically fetch content ONLY if user has bought/registered for the course
      // DO NOT fetch content if user hasn't paid/registered (even for free courses)
      final authHasBought = _selectedCourse?['auth_has_bought'] == true;

      // Only fetch content if user has actually bought/registered for the course
      // For free courses, user must still register (authHasBought must be true)
      if (authHasBought) {
        debugPrint('User has access, fetching content...');
        _isLoadingDetails = false;
        notifyListeners();
        await fetchCourseContent(id, isBundle: isBundle);
      } else {
        debugPrint('User does not have access - content will not be loaded');
        // Clear any previous content
        _courseContent = [];
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load course details';
      debugPrint('Error: $e');
    }

    _isLoadingDetails = false;
    notifyListeners();
  }

  /// Fetch course content (chapters, lessons, files, etc.)
  /// For bundles, this will fetch the list of webinars inside the bundle
  Future<void> fetchCourseContent(int courseId, {bool isBundle = false}) async {
    _isLoadingContent = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint(
          '=== FETCHING COURSE CONTENT for ID: $courseId (isBundle: $isBundle) ===');

      if (isBundle) {
        // Prefer panel/bundles/{id} to get webinars with progress_percent and is_completed
        final bundleWithProgress =
            await _courseService.getBundleWithProgress(courseId);
        final bundleWebinars = bundleWithProgress?['webinars'] as List?;

        if (bundleWebinars != null && bundleWebinars.isNotEmpty) {
          debugPrint(
              'Using webinars from panel/bundles (with progress): ${bundleWebinars.length} webinars');
          final rawList = bundleWebinars
              .map((webinar) => {
                    'id': webinar['id'],
                    'title': webinar['title'] ?? 'Cours',
                    'type': 'webinar',
                    'thumbnail': webinar['thumbnail'] ?? webinar['image'],
                    'duration': webinar['duration'],
                    'link': '/courses/${webinar['id']}',
                    'can': {'view': true},
                    'order': _bundleWebinarOrderValue(webinar),
                    'progress_percent': webinar['progress_percent'],
                    'is_completed': webinar['is_completed'] == true,
                  })
              .toList();
          rawList.sort(_compareBundleItemOrder);
          _courseContent = [
            {
              'title': 'Cours inclus dans ce pack',
              'type': 'bundle_webinars',
              'items': rawList,
            }
          ];
        } else {
          // Fallback: webinars from selectedCourse or getBundleWebinars (no progress)
          final fallbackWebinars = _selectedCourse?['webinars'];
          if (fallbackWebinars != null &&
              fallbackWebinars is List &&
              fallbackWebinars.isNotEmpty) {
            debugPrint(
                'Using webinars from bundle details: ${fallbackWebinars.length} webinars');
            final rawList = fallbackWebinars
                .map((webinar) => {
                      'id': webinar['id'],
                      'title': webinar['title'] ?? 'Cours',
                      'type': 'webinar',
                      'thumbnail': webinar['thumbnail'] ?? webinar['image'],
                      'duration': webinar['duration'],
                      'link': '/courses/${webinar['id']}',
                      'can': {'view': true},
                      'order': _bundleWebinarOrderValue(webinar),
                      'progress_percent': webinar['progress_percent'],
                      'is_completed': webinar['is_completed'] == true,
                    })
                .toList();
            rawList.sort(_compareBundleItemOrder);
            _courseContent = [
              {
                'title': 'Cours inclus dans ce pack',
                'type': 'bundle_webinars',
                'items': rawList,
              }
            ];
          } else {
            debugPrint('Fetching bundle webinars from API...');
            final webinars =
                await _courseService.getBundleWebinars(courseId);
            debugPrint('Loaded ${webinars.length} webinars from bundle');
            if (webinars.isNotEmpty) {
              final rawList = webinars
                  .map((webinar) => {
                        'id': webinar.id,
                        'title': webinar.title ?? 'Cours',
                        'type': 'webinar',
                        'thumbnail': webinar.thumbnail ?? webinar.image,
                        'duration': webinar.duration,
                        'link': '/courses/${webinar.id}',
                        'can': {'view': true},
                        'order': webinar.order,
                        'progress_percent': webinar.progressPercent,
                        'is_completed': (webinar.progressPercent ?? 0) >= 100,
                      })
                  .toList();
              rawList.sort(_compareBundleItemOrder);
              _courseContent = [
                {
                  'title': 'Cours inclus dans ce pack',
                  'type': 'bundle_webinars',
                  'items': rawList,
                }
              ];
            } else {
              _courseContent = [];
            }
          }
        }
      } else {
        // For regular courses, fetch content normally
        _courseContent = await _courseService.getContent(courseId);
      }

      debugPrint('Loaded ${_courseContent.length} chapters/sections');
    } catch (e) {
      _errorMessage = 'Failed to load course content';
      debugPrint('Error loading content: $e');
    }

    _isLoadingContent = false;
    notifyListeners();
  }

  /// Search courses
  Future<Map<String, dynamic>> search(String query) async {
    _isLoadingCourses = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _courseService.search(query);
      _isLoadingCourses = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = 'Search failed';
      _isLoadingCourses = false;
      notifyListeners();
      return {
        'courses': <CourseModel>[],
        'users': <Map<String, dynamic>>[],
        'organizations': <Map<String, dynamic>>[],
      };
    }
  }

  /// Toggle favorite/wishlist
  Future<Map<String, dynamic>> toggleFavorite(int courseId,
      {bool isBundle = false}) async {
    try {
      final result =
          await _courseService.toggleFavorite(courseId, isBundle: isBundle);

      // Update the local state if we have the course details
      if (result['success'] == true &&
          _selectedCourse != null &&
          _selectedCourse!['id'] == courseId) {
        final currentFavorite = _selectedCourse!['is_favorite'] == true;
        _selectedCourse!['is_favorite'] = !currentFavorite;
        notifyListeners();
      }

      return result;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Load initial data
  Future<void> loadInitialData() async {
    // Run all in parallel
    await Future.wait([
      fetchFeaturedCourses(),
      fetchCourses(),
      fetchBundles(),
      fetchTrendCategories(),
      fetchCategories(),
    ]);
  }

  /// Clear selected course
  void clearSelectedCourse() {
    _selectedCourse = null;
    _courseContent = [];
    notifyListeners();
  }

  /// Order value for a webinar map from API. Uses order, sort_order, position, pivot.order.
  /// Returns null if no order defined (API: null order = display last).
  static int? _bundleWebinarOrderValue(dynamic webinar) {
    if (webinar is! Map) return null;
    final map = webinar;
    final v = map['order'] ?? map['sort_order'] ?? map['position'];
    if (v != null) {
      final n = int.tryParse(v.toString());
      if (n != null) return n;
    }
    final pivot = map['pivot'];
    if (pivot is Map && pivot['order'] != null) {
      final n = int.tryParse(pivot['order'].toString());
      if (n != null) return n;
    }
    return null;
  }

  static int _bundleWebinarOrder(dynamic webinar) {
    final v = _bundleWebinarOrderValue(webinar);
    if (v != null) return v;
    if (webinar is Map) {
      final id = webinar['id'];
      if (id != null) return int.tryParse(id.toString()) ?? 999999;
    }
    return 999999;
  }

  /// Sort bundle items: non-null order first (ASC), then null order (stable by id).
  /// API: "Les cours sont déjà triés par order (NULL en dernier, puis ASC)"
  static int _bundleItemOrder(Map<String, dynamic> item) {
    final order = item['order'];
    if (order != null) {
      final n = order is int ? order : int.tryParse(order.toString());
      if (n != null) return n;
    }
    // Null order → put last: use large value so they sort after all ordered items
    final id = item['id'];
    if (id != null) return 1000000 + (id is int ? id : (int.tryParse(id.toString()) ?? 0));
    return 999999;
  }

  /// Comparator: null order last, then ASC by order, then by id for nulls.
  static int _compareBundleItemOrder(Map<String, dynamic> a, Map<String, dynamic> b) {
    final orderA = a['order'];
    final orderB = b['order'];
    final hasOrderA = orderA != null && (orderA is int ? true : int.tryParse(orderA.toString()) != null);
    final hasOrderB = orderB != null && (orderB is int ? true : int.tryParse(orderB.toString()) != null);
    if (hasOrderA && hasOrderB) {
      final na = orderA is int ? orderA : int.tryParse(orderA.toString()) ?? 0;
      final nb = orderB is int ? orderB : int.tryParse(orderB.toString()) ?? 0;
      return na.compareTo(nb);
    }
    if (!hasOrderA && !hasOrderB) {
      final idA = a['id'] is int ? a['id'] as int : int.tryParse(a['id']?.toString() ?? '0') ?? 0;
      final idB = b['id'] is int ? b['id'] as int : int.tryParse(b['id']?.toString() ?? '0') ?? 0;
      return idA.compareTo(idB);
    }
    return hasOrderA ? -1 : 1; // a has order, b hasn't → a first; else b first
  }
}
