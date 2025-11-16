// core/service/api_service/Model/organization_models.dart

class UserOrganization {
  final String id;
  final String user;
  final Organization organization;
  final List<OrganizationRole> roles;
  final String joinedAt;

  UserOrganization({
    required this.id,
    required this.user,
    required this.organization,
    required this.roles,
    required this.joinedAt,
  });

  factory UserOrganization.fromJson(Map<String, dynamic> json) {
    return UserOrganization(
      id: json['_id'] as String? ?? '',
      user: json['user'] as String? ?? '',
      organization: Organization.fromJson(json['organization'] as Map<String, dynamic>),
      roles: (json['roles'] as List<dynamic>?)
          ?.map((role) => OrganizationRole.fromJson(role as Map<String, dynamic>))
          .toList() ?? [],
      joinedAt: json['joinedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'organization': organization.toJson(),
      'roles': roles.map((role) => role.toJson()).toList(),
      'joinedAt': joinedAt,
    };
  }
}

class Organization {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final bool active; // Changed from String to bool
  final String createdAt;

  Organization({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    required this.active,
    required this.createdAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      active: json['active'] as bool? ?? false, // Now handles bool
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'logoUrl': logoUrl,
      'active': active,
      'createdAt': createdAt,
    };
  }
}

class OrganizationRole {
  final String id;
  final String name;
  // Removed other fields since they're not in the response

  OrganizationRole({
    required this.id,
    required this.name,
  });

  factory OrganizationRole.fromJson(Map<String, dynamic> json) {
    return OrganizationRole(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}