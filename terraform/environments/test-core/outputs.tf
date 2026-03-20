output "environment_context" {
  description = "Normalized environment metadata for module composition and downstream automation."
  value = {
    org_slug      = var.org_slug
    environment   = var.environment_name
    phase         = var.phase_name
    name_prefix   = local.name_prefix
    primary_zone  = local.zone
    dns_domain    = var.dns_domain
    network_cidrs = var.network_cidrs
    tags          = local.common_tags
  }
}

output "phase1_service_alignment" {
  description = "Phase 1 service groupings aligned to the service catalog for test-core baseline provisioning."
  value       = local.phase1_service_catalog
}
