class ResumeService {
  static String translateToProfessional(String moduleId) {
    switch (moduleId) {
      case 'navigation':
        return 'Proficient in POSIX-compliant filesystem traversal and hierarchical data management.';
      case 'creation':
        return 'Experienced in directory architecture design and environment bootstrapping.';
      case 'manipulation':
        return 'Skilled in high-integrity data migration and recursive filesystem restructuring.';
      case 'deletion':
        return 'Expert in resource cleanup, disk space optimization, and idempotent deletion policies.';
      case 'permissions':
        return 'Advanced knowledge of Unix access control lists (ACLs) and security posture hardening.';
      default:
        return 'Mastery of specialized terminal operations.';
    }
  }

  static List<String> buildResume(List<String> completedModules) {
    return completedModules.map((id) => translateToProfessional(id)).toList();
  }
}
