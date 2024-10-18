import 'package:doggi_app/screens/Instructions/article_list_page.dart';
import 'package:flutter/material.dart';


class ArticlesContent extends StatefulWidget {
  const ArticlesContent({super.key});

  @override
  State<ArticlesContent> createState() => _ArticlesContentState();
}

class _ArticlesContentState extends State<ArticlesContent> {
  @override
  Widget build(BuildContext context) {
    return ArticleListPage();
  }
}
