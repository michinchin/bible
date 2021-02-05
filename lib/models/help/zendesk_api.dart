import 'package:tec_util/tec_util.dart' as tec;

const zendeskApiUrl = 'https://support.tecartabible.com/api/v2/help_center';
const articleKey = 'articles';
const authKey =
    'bWlrZUB0ZWNhcnRhLmNvbS90b2tlbjpCWDlFWFdEdGhQVE1YZ215WVNkSFBxTWNaNzNtcnVQd1BUVlRDZ0Nh';
const categoryId = '200291314';

class ZendeskApi {

  static Future<List<ZendeskArticle>> fetchSearch(String query) async {
    final parameters = <String, String>{'query': query, 'category': categoryId};
    final queryParams = Uri(queryParameters: parameters).query;
    final json = await tec.sendHttpRequest(tec.HttpRequestType.get,
        headers: {'Authorization': 'Basic $authKey'},
        url: '$zendeskApiUrl/articles/search.json?$queryParams',
        completion: (status, json, dynamic error) => Future.value(json));
        
    if (json != null) {
      final articles = <ZendeskArticle>[];
      for (final each in json['results']) {
        articles.add(ZendeskArticle.fromJson(tec.as<Map<dynamic, dynamic>>(each)));
      }
      return articles;
    }
    return [];
  }

  // need to grab sections and then articles for each articles
  static Future<List<ZendeskSection>> fetchSections() async {
    final response = await tec.httpGet('$zendeskApiUrl/en-us/categories/$categoryId/sections.json');
    final json = tec.parseJsonSync(response?.body ?? '');
    if (json != null) {
      final sections = <ZendeskSection>[];
      for (final each in json['sections']) {
        final section = ZendeskSection.fromJson(tec.as<Map<dynamic, dynamic>>(each));
        sections.add(section);
      }
      return sections;
    }
    return [];
  }

  /// all articles available
  static Future<List<ZendeskArticle>> fetchArticles({int sectionId}) async {
    final response = await tec.httpGet(
        '$zendeskApiUrl/en-us${sectionId != null ? '/sections/$sectionId' : ''}/articles.json');
    final json = tec.parseJsonSync(response?.body ?? '');
    if (json != null) {
      final articles = <ZendeskArticle>[];
      for (final each in json[articleKey]) {
        articles.add(ZendeskArticle.fromJson(tec.as<Map<dynamic, dynamic>>(each)));
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
        name: tec.as<String>(data['name']),
        id: tec.as<int>(data['id']),
        url: tec.as<String>(data['url']),
        locale: tec.as<String>(data['locale']),
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
      title: tec.as<String>(data['title']),
      id: tec.as<int>(data['id']),
      url: tec.as<String>(data['url']),
      authorId: tec.as<int>(data['author_id']),
      editedAt: DateTime.parse(tec.as<String>(data['edited_at'])),
      body: tec.as<String>(data['body']),
      locale: tec.as<String>(data['locale']),
      snippet: tec.as<String>(data['snipppet']));
}
