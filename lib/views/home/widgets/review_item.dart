import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shopdemo/services/database.dart';
import 'package:shopdemo/services/local_notification_service.dart';
import 'package:shopdemo/views/home/widgets/review_card.dart';

class ReviewItem extends StatefulWidget {
  final int productId;
  const ReviewItem({super.key, required this.productId});

  @override
  State<ReviewItem> createState() => _WriteReviewFormState();
}

class _WriteReviewFormState extends State<ReviewItem> {
  int _currentRating = 0; 
  final TextEditingController _commentController = TextEditingController();
  final List<File> _selectedImages = []; 
  final ImagePicker _picker = ImagePicker();
  bool _isDataLoading = false;
  bool _checkReview = false;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  Future<void> _loadExistingReview() async {
    setState(() {
      _isDataLoading = true;
    });
    try {
      final reviews = await DatabaseHelper.instance.getReviewsByProductId(widget.productId);
      if (reviews.isNotEmpty) {
        _checkReview = true;
        final lastReview = reviews.last;
        _currentRating = lastReview[DatabaseHelper.columnRating] as int;
        _commentController.text = lastReview[DatabaseHelper.columnComment] as String;
      }
    } catch (e) {
      print("Lỗi khi tải review: $e");
    } finally {
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _handlePermissionAndPick(ImageSource source) async {
    Permission permisson;
    if (source == ImageSource.camera) {
      permisson = Permission.camera;
    } else {
      permisson = Permission.photos;
    }

    if (await permisson.isGranted) {
      _pickImage(source);
    } else if (await permisson.isDenied){
      final status = await permisson.request();
      if (status.isGranted) {
        _pickImage(source);
      } 
    } else if (await permisson.isPermanentlyDenied) {
      _showSettingsDialog();
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cần cấp quyền"),
        content: const Text("Bạn cần cấp quyền truy cập để thực hiện tính năng này trong phần Cài đặt."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            }, 
            child: const Text("Mở Cài đặt")
          ),
        ],
      ),
    );
  }

  void _saveReview() async {
    Map<String, dynamic> review = {
      DatabaseHelper.columnProductId: widget.productId,
      DatabaseHelper.columnComment: _commentController.text,
      DatabaseHelper.columnRating: _currentRating,
    };
    final id = await DatabaseHelper.instance.insertReview(review);
    
    if (mounted) {
      await LocalNotificationService.showNotification(
        "Shop Demo",
        "Đã lưu đánh giá sản phẩm"
      );
      _loadExistingReview();
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.of(context).pop();
                _handlePermissionAndPick(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.of(context).pop();
                _handlePermissionAndPick(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDataLoading) {
      return const Center(child: CircularProgressIndicator());
    } 
    if (_checkReview) {
      return ReviewCard( 
        productId: widget.productId,
        comment: _commentController.text,
        rating: _currentRating,
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bạn cảm thấy sản phẩm này thế nào?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                iconSize: 40,
                icon: Icon(
                  index < _currentRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    _currentRating = index + 1;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Hãy chia sẻ cảm nhận của bạn về sản phẩm...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              GestureDetector(
                onTap: _showImageSourceActionSheet,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.grey),
                      Text("Thêm ảnh", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              ..._selectedImages.map((file) {
                return Stack(
                  clipBehavior: Clip.none, 
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -15,
                      right: -15,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedImages.remove(file);
                          });
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveReview,
              child: const Text(
                "Gửi đánh giá",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}