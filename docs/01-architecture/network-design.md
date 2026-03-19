# Network Design

## Segmentation Model
NorthGate uses three logical segments in each environment:

1. **mgmt segment**
   - Purpose: admin access, configuration traffic, and observability.
   - Access policy: restricted to operator endpoints and automation runners.
2. **svc segment**
   - Purpose: east-west service traffic between platform and app hosts.
   - Access policy: allow required service ports only.
3. **ingress segment (optional per environment)**
   - Purpose: north-south client access to exposed services.
   - Access policy: tightly scoped to published service endpoints.

## Addressing Convention
- CIDR blocks are assigned per environment and segment.
- CIDR naming format: `<env>-<segment>-cidr`.
- Static infrastructure addresses (for control endpoints) are reserved at the low end of each subnet.

## Traffic Policy
- Default deny between segments unless explicitly allowed.
- Management services are reachable only from mgmt-approved sources.
- Inter-environment routing is disabled by default.

## DNS and Naming
- Hostnames follow: `ng-<env>-<role>-<index>` (example: `ng-test-core-cfg-01`).
- Forward and reverse DNS entries are required for long-lived hosts.

## Validation Requirements
- Terraform/OpenTofu validates CIDR overlap and route definitions.
- Ansible connectivity checks validate management reachability before role execution.
