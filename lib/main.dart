import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'dart:io';

class FirmwareBundle {
  final String name;
  final String package;
  final String description;

  FirmwareBundle({
    required this.name,
    required this.package,
    required this.description,
  });

  factory FirmwareBundle.fromJson(Map<String, dynamic> json) {
    return FirmwareBundle(
      name: json['name'] as String,
      package: json['package'] as String,
      description: json['description'] as String,
    );
  }
}

Future<void> main() async {
  await YaruWindowTitleBar.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: yaru.theme,
          darkTheme: yaru.darkTheme,
          home: _Home(),
          title: "PlutoOS System Configuration",
        );
      },
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YaruWindowTitleBar(),
      body: YaruMasterDetailPage(
        length: 3,
        tileBuilder: (context, index, selected, availableWidth) {
          if (index == 0) {
            return const YaruMasterTile(
              title: Text('System Updates'),
              leading: Icon(YaruIcons.update_available_filled),
            );
          } else if (index == 1) {
            return const YaruMasterTile(
              title: Text('Linux Environment'),
              leading: Icon(YaruIcons.ubuntu_logo_simple),
            );
          } else if (index == 2) {
            return const YaruMasterTile(
              title: Text("Drivers & Firmware"),
              leading: Icon(YaruIcons.drive_optical_filled),
            );
          }

          throw Exception("Index misalligned?");
        },
        pageBuilder: (context, index) {
          if (index == 0) {
            return SystemUpdatesPage();
          } else if (index == 1) {
            return LinuxEnvironmentPage();
          } else if (index == 2) {
            return DriversPage();
          }

          return Center(child: Text("Failed to load page"));
        },
      ),
    );
  }
}

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  List<FirmwareBundle> firmwareBundles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFirmwareBundles();
  }

  Future<void> loadFirmwareBundles() async {
    try {
      // Get the path to the data directory relative to the executable
      final String executablePath = Platform.resolvedExecutable;
      final Directory executableDir = Directory(executablePath).parent;
      final File jsonFile = File('/code/PlutoDevelopment/pluto_os_system_config/data/firmware_bundles.json');
      
      // Check if file exists, if not create a default one
      if (!await jsonFile.exists()) {
        throw Exception("bruh");
        await createDefaultFirmwareBundlesFile(jsonFile);
      }
      
      final String jsonString = await jsonFile.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      
      setState(() {
        firmwareBundles = jsonList.map((json) => FirmwareBundle.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error appropriately in your app
      print('Error loading firmware bundles: $e');
    }
  }

  Future<void> createDefaultFirmwareBundlesFile(File file) async {
    // final defaultData = [
    //   {
    //     "name": "AMD Radeon GPU",
    //     "package": "pluto-firmware-amdgpu",
    //     "description": "Firmware for AMD Radeon graphics cards and APUs"
    //   },
    //   {
    //     "name": "NVIDIA GPU",
    //     "package": "pluto-firmware-nvidia",
    //     "description": "Firmware for NVIDIA GeForce and Quadro graphics cards"
    //   },
    //   {
    //     "name": "Intel Wireless",
    //     "package": "pluto-firmware-intel-wifi",
    //     "description": "Firmware for Intel wireless network adapters"
    //   },
    //   {
    //     "name": "Realtek Audio",
    //     "package": "pluto-firmware-realtek-audio",
    //     "description": "Firmware for Realtek audio chipsets"
    //   },
    //   {
    //     "name": "Broadcom WiFi",
    //     "package": "pluto-firmware-broadcom-wifi",
    //     "description": "Firmware for Broadcom wireless network adapters"
    //   }
    // ];

    // await file.parent.create(recursive: true);
    // await file.writeAsString(json.encode(defaultData));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "PlutoOS Firmware Bundles",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  loadFirmwareBundles();
                },
                tooltip: 'Refresh firmware bundles',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(
                  decelerationRate: ScrollDecelerationRate.fast
                ),
                itemCount: firmwareBundles.length,
                itemBuilder: (context, index) {
                  final bundle = firmwareBundles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: 300,
                      child: Card.filled(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bundle.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bundle.package,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bundle.description,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class LinuxEnvironmentPage extends StatelessWidget {
  const LinuxEnvironmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: Text(
              'The chosen Linux Environment of PlutoOS determines how things like native Linux applications and the terminal behaves. Typically, just pick the one you\'re most familiar with.',
            ),
          ),
          Column(
            children: [
              YaruRadioButton<String>(
                value: 'arch',
                groupValue: 'arch', // You'll want to make this stateful
                onChanged: (value) {
                  // Handle arch selection
                },
                title: Text('Arch-like'),
                subtitle: Text('Bleeding edge terminal updates and access to the pacman package manager.'),
              ),
              YaruRadioButton<String>(
                value: 'ubuntu',
                groupValue: 'arch', // You'll want to make this stateful
                onChanged: (value) {
                  // Handle ubuntu selection
                },
                title: Text('Ubuntu-like'),
                subtitle: Text('More stable terminal and access to the apt package manager.'),
              ),
            ],
          ),
          /* Row(
            children: [
              Flexible(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/arch_logo.svg', height: 80, width: 80),
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            const Text(
                              'Arch-like',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Wrap(children: [const Text("Bleeding edge terminal updates and access to the pacman package manager.")])
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/ubuntu_logo.svg', height: 80, width: 80),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Ubuntu-like',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(child: const Text("More stable terminal and access to the apt package manager."))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ), */
        ],
      ),
    );
  }
}

class SystemUpdatesPage extends StatelessWidget {
  const SystemUpdatesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: Text(
              'PlutoOS generally releases new major updates once a month to ensure that you have the latest and greatest software.',
            ),
          ),
          Row(
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
        ],
      ),
    );
  }
}
