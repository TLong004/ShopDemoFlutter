import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownDemo extends StatelessWidget {
  final String data = """
# Tiêu đề lớn (H1)
Đây là một đoạn văn bản có **in đậm** và *in nghiêng*.

## Danh sách công việc:
1. Hoàn thành App Medical Booking
2. Tích hợp BLoC
3. Học về Markdown

[Link đến Google](https://google.com)
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Markdown trong Flutter")),
      body: Markdown(
        data: data,
        onTapLink: (text, href, title) {
          print("Người dùng nhấn vào link: $href");
        },
      ),
    );
  }
}