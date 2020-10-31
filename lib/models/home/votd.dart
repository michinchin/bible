import 'package:tec_util/tec_util.dart' as tec;

final _year = DateTime.now().year;
final _jan1 = DateTime.utc(_year, 1, 1);
final _ordinalDay = DateTime.now().difference(_jan1).inDays;
final _parameters = '/home/votd-$_year.json';

class VOTD {
  final String url;
  final String refs;

  VOTD({this.url, this.refs});

  factory VOTD.fromJson(Map<String, dynamic> json) {
    final specials = tec.as<Map<String, dynamic>>(json['specials']);
    final data = tec.as<List<dynamic>>(json['data']);
    final isSpecial = tec.isNullOrEmpty(specials['$_ordinalDay']);
    final image = tec.as<String>(isSpecial ? data[_ordinalDay][1] : specials['$_ordinalDay'][1]);
    final refs = tec.as<String>(isSpecial ? data[_ordinalDay][0] : specials['$_ordinalDay'][0]);
    return VOTD(
      url: '${tec.streamUrl}/votd/$image',
      refs: refs,
    );
  }

  static Future<VOTD> fetch() async {
    final json = await tec.sendHttpRequest<Map<String, dynamic>>(tec.HttpRequestType.get,
        url: '${tec.streamUrl}$_parameters', completion: (code, json, dynamic error) async {
      return json;
    });

    if (json != null) {
      return VOTD.fromJson(json);
    } else {
      return null;
    }
  }
}
