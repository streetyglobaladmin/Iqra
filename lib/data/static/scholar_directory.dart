/// Scholar directory profiles. In production this is populated by the
/// admin CMS (Nuerizo Control Center → Manage Teachers). Ships empty by
/// default per the "no fake institution/reviews" requirement — the
/// screen shows a genuine "No scholars yet" empty state until an admin
/// or teacher actually creates a profile through the app.
class ScholarProfile {
  final String id;
  final String name;
  final String specialty;
  final List<String> tags;
  final bool online;

  const ScholarProfile({
    required this.id,
    required this.name,
    required this.specialty,
    required this.tags,
    this.online = false,
  });
}
