import 'package:tec_util/tec_util.dart';
import 'package:http/http.dart' as http;

const zendeskApiUrl = 'https://support.tecartabible.com/api/v2/help_center';
const articleKey = 'articles';
const authKey = 'h N W Z 0 B U Z r l W b c n R h L m N v b S 9 0 b 2 t l b j p C W D l F '
    'W F d E d G h Q V E 1 Y Z 2 1 5 W V N k S F B x T W N a N z N t c n V Q d 1 B U V l R D Z 0 N h';
const categoryId = '200291314';

class ZendeskApi {
  static String decodeKey(String key) {
    final trimmed = key.replaceAll(' ', '');
    return trimmed.substring(0, 12).reversed() + trimmed.substring(12, trimmed.length);
  }

  static Future<List<ZendeskArticle>> fetchSearch(String query) async {
    final parameters = <String, String>{'query': query, 'category': categoryId};
    final queryParams = Uri(queryParameters: parameters).query;
    final json = await httpRequestMap('$zendeskApiUrl/articles/search.json?$queryParams',
        headers: {'Authorization': 'Basic ${decodeKey(authKey)}'});

    if (json != null) {
      final articles = <ZendeskArticle>[];
      for (final each in json['results']) {
        articles.add(ZendeskArticle.fromJson(as<Map<dynamic, dynamic>>(each)));
      }
      return articles;
    }
    return [];
  }

  // need to grab sections and then articles for each articles
  static Future<List<ZendeskSection>> fetchSections() async {
    final response =
        await http.get(Uri.parse('$zendeskApiUrl/en-us/categories/$categoryId/sections.json'));
    final json = parseJsonSync(response?.body ?? '');
    if (json != null) {
      final sections = <ZendeskSection>[];
      for (final each in json['sections']) {
        final section = ZendeskSection.fromJson(as<Map<dynamic, dynamic>>(each));
        sections.add(section);
      }
      return sections;
    }
    return [];
  }

  /// all articles available
  static Future<List<ZendeskArticle>> fetchArticles({int sectionId}) async {
    final response = await http.get(Uri.parse(
        '$zendeskApiUrl/en-us${sectionId != null ? '/sections/$sectionId' : ''}/articles.json'));
    final json = parseJsonSync(response?.body ?? '');
    if (json != null) {
      final articles = <ZendeskArticle>[];
      for (final each in json[articleKey]) {
        articles.add(ZendeskArticle.fromJson(as<Map<dynamic, dynamic>>(each)));
      }
      return articles;
    }
    return [];
  }
}

class ZendeskSection {
  final String name;
  final int id;
  final String url;
  final String locale;
  final List<ZendeskArticle> articles;

  const ZendeskSection({this.name, this.id, this.url, this.locale, this.articles});

  ZendeskSection copyWith(
          {String name, int id, String url, String locale, List<ZendeskArticle> articles}) =>
      ZendeskSection(
          name: name ?? this.name,
          id: id ?? this.id,
          locale: locale ?? this.locale,
          articles: articles ?? this.articles);

  factory ZendeskSection.fromJson(Map<dynamic, dynamic> data) => ZendeskSection(
        name: as<String>(data['name']),
        id: as<int>(data['id']),
        url: as<String>(data['url']),
        locale: as<String>(data['locale']),
      );
}

class ZendeskArticle {
  final String title;
  final int id;
  final String url;
  final int authorId;
  final DateTime editedAt;
  final String body;
  final String locale;
  final String snippet;

  const ZendeskArticle(
      {this.title,
      this.id,
      this.url,
      this.authorId,
      this.editedAt,
      this.body,
      this.locale,
      this.snippet});

  factory ZendeskArticle.fromJson(Map<dynamic, dynamic> data) => ZendeskArticle(
      title: as<String>(data['title']),
      id: as<int>(data['id']),
      url: as<String>(data['url']),
      authorId: as<int>(data['author_id']),
      editedAt: DateTime.parse(as<String>(data['edited_at'])),
      body: as<String>(data['body']),
      locale: as<String>(data['locale']),
      snippet: as<String>(data['snipppet']));
}

extension on String {
  String reversed() => String.fromCharCodes(runes.toList().reversed);
}
