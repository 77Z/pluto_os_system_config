import 'package:flutter/material.dart';
import 'package:pluto_os_system_config/main.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class SystemUpdatesPage extends StatefulWidget {
  const SystemUpdatesPage({super.key});

  @override
  State<StatefulWidget> createState() => SystemUpdatesPageState();
}

class SystemUpdatesPageState extends State<SystemUpdatesPage> {
  String latestVersion = "UNKNOWN";
  String yourPlutoVersion = "UNKNOWN";

  @override
  void initState() {
    super.initState();

    getLatestPlutoOSVersion();
    getYourPlutoOSVersion();
  }

  Future<void> getLatestPlutoOSVersion() async {
    try {
      var response = await http.get(
        Uri.parse("https://pluto-freeze.77z.dev/api/v1/latestVersion"),
      );

      setState(() {
        latestVersion = response.body;
      });
    } catch (e) {}
  }

  Future<void> getYourPlutoOSVersion() async {
    final File versionFile = File("/pluto/version");

    if (!await versionFile.exists()) return;

    String versionRaw = versionFile.readAsStringSync();
    if (versionRaw.endsWith("\n")) versionRaw = versionRaw.replaceAll("\n", "");

    setState(() {
      yourPlutoVersion = versionRaw;
    });
  }

  bool compareVersions(String currentVer, String compareTo) {
    final currentParts = currentVer.split("-");
    final compareToParts = compareTo.split("-");

    if (currentParts.length != 2 || compareToParts.length != 2) {
      return false; // Invalid format
    }

    final currentYear = int.tryParse(currentParts[0]);
    final currentMonth = int.tryParse(currentParts[1]);
    final compareYear = int.tryParse(compareToParts[0]);
    final compareMonth = int.tryParse(compareToParts[1]);

    if (currentYear == null ||
        currentMonth == null ||
        compareYear == null ||
        compareMonth == null) {
      return false; // Invalid numbers
    }

    // Return true if current version is older than compareTo version
    if (currentYear < compareYear) {
      return true;
    } else if (currentYear == compareYear) {
      return currentMonth < compareMonth;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 15,
        children: [
          Center(
            child: Text(
              'PlutoOS generally releases new major updates once a month to ensure that you have the latest and greatest software.',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Text('Update Frequency'),
              SizedBox(width: 16),
              DropdownMenu(
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'daily', label: 'Daily'),
                  DropdownMenuEntry(value: 'weekly', label: 'Weekly'),
                  DropdownMenuEntry(value: 'monthly', label: 'Monthly'),
                  DropdownMenuEntry(value: 'never', label: 'Never'),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Text("Latest Pluto Version"),

              if (latestVersion == "UNKNOWN")
                const CircularProgressIndicator()
              else
                Text(latestVersion),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Text("Installed Pluto Version"),
              if (yourPlutoVersion == "UNKNOWN")
                const CircularProgressIndicator()
              else
                Text(yourPlutoVersion),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 10,
            children: [
              TextButton(
                child: const Text("Check For Updates"),
                onPressed: () => {
                  getLatestPlutoOSVersion(),
                  setState(() {
                    latestVersion = "UNKNOWN";
                  })
                }
              ),
              if (latestVersion != "UNKNOWN" &&
                  yourPlutoVersion != "UNKNOWN" &&
                  compareVersions(yourPlutoVersion, latestVersion))
                ElevatedButton(
                  onPressed: () => {},
                  child: const Text("Update Now"),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
