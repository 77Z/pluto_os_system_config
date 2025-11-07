import 'package:http/http.dart' as http;
import 'package:pluto_os_system_config/config.dart';
import 'package:pluto_os_system_config/data/models/latest_version_info.dart';

class LatestVersionApi {
  Future<LatestVersionInfo?> getLatestVersionInfo() async {
    var response = await http.get(Uri.parse("$API_URL/latestVersions"));

    if (response.statusCode == 200) {
      return versionInfoFromJson(response.body);
    }
    return null;
  }
}