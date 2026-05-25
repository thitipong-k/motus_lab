class DoipProfile {
  final String name;
  final String description;
  final String? ipAddress; // null means auto-discovery via UDP broadcast

  const DoipProfile({
    required this.name,
    required this.description,
    this.ipAddress,
  });
}

const List<DoipProfile> doipProfiles = [
  DoipProfile(
    name: "Auto-Discover (Generic DoIP)",
    description: "Finds vehicles automatically via UDP Broadcast",
    ipAddress: null,
  ),
  DoipProfile(
    name: "BMW F/G/I-Series (ENET)",
    description: "Direct connection via standard BMW ENET fallback IP",
    ipAddress: "169.254.1.205",
  ),
  DoipProfile(
    name: "Mercedes-Benz (DoIP)",
    description: "Direct connection for modern MB chassis (W222, W205, etc.)",
    ipAddress: "169.254.255.42",
  ),
  DoipProfile(
    name: "Volvo / JLR (DoIP)",
    description: "Direct connection for Volvo SPA and Jaguar Land Rover",
    ipAddress: "169.254.0.42",
  ),
];
