import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news/text_with_style.dart';
import 'package:url_launcher/url_launcher.dart';


class ListNews extends StatefulWidget {
  const ListNews({Key? key}) : super(key: key);

  @override
  State<ListNews> createState() => _ListNewsState();
}

class _ListNewsState extends State<ListNews> {

  // VARIABLES
  List newsArticles = [];

  // MÉTHODE
  chargeNews() async {
    const String apiKey = 'ddf7a69fa54b413fa803d403a6e3496f'; // clé API
    const String apiUrl =
        'https://newsapi.org/v2/everything?q=apple&from=2023-07-31&to=2023-07-31&sortBy=popularity&apiKey=$apiKey'; // Url API
    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          newsArticles = jsonData['articles'];
        });
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  Column information({required int index, required Map article}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10,),
        Wrap(children: [
          TextWithStyle(data: article['title'], weight: FontWeight.bold, size: 15,)
        ]
        ),
        const SizedBox(height: 5,),
        Wrap(children: [
          TextWithStyle(data: article['publishedAt'], color: Colors.grey,)
        ]
        ),
        const SizedBox(height: 5,),
        Wrap(children:
        [
          TextWithStyle(data: article['description'], size: 12, maxLines: 2,)
        ]
        )
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri(scheme: "https", host: url);
    if(!await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    )) {
      throw "Can not launch url";
    }
  }

  // Initialisation de l'application
  @override
  void initState() {
    super.initState();
    chargeNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Actualités')),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          itemCount:  min(newsArticles.length, 20),
          itemBuilder: (BuildContext context, int index) {
            Map article = newsArticles[index];
            return InkWell(
              onTap: () async {
                _launchURL(article['url']);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10, left: 5, right: 4.5),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 3, // Use a flex value for distribution
                        child: information(index: index, article: article),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        flex: 2, // Use a flex value for distribution
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Image(
                            image: NetworkImage(article['urlToImage'],
                            ),
                          ),
                        ),
                      ),
                      const Divider(color: Color.fromARGB(
                          255, 136, 136, 136), thickness: 1,),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
