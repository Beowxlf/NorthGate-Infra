# Success Criteria

## Primary Success Metrics

### SC-01 Rebuild From Zero
- All supported environments can be rebuilt from empty virtualization capacity using repository procedures only.
- No undocumented manual steps are required.

### SC-02 Layer Clarity and Ownership
- Every infrastructure component is mapped to one of:
  - provisioning (Terraform/OpenTofu),
  - configuration (Ansible),
  - application (application deployment workflow).
- Ownership and dependencies are documented in the service catalog.

### SC-03 Environment Determinism
- `test-core`, `workbench`, and `app-hosting` each have explicit boundaries, naming rules, and deployment intent.
- Environment-specific differences are represented by versioned configuration, not implicit operator behavior.

### SC-04 Controlled Change Flow
- Git is the only accepted source for infrastructure changes.
- CI gates validate syntax, policy, and cross-layer consistency before merge.
- Promotion order is documented and enforced.

### SC-05 Recoverability
- Failure and recovery runbooks define restore order, dependencies, and validation checks.
- Recovery has a tested path for identity, telemetry, and application service restoration.

## Phase Exit Criteria
- **Phase 0:** Documentation baseline exists for all required sections.
- **Phase 1:** Terraform/OpenTofu/Ansible/Packer structure maps to documentation.
- **Phase 2:** Domain services, control node, and Wazuh stack deployed and validated.
- **Phase 3:** Metrics/dashboards available and alert baselines defined.
- **Phase 4:** Controlled attack simulation validates detection and response coverage.
- **Phase 5:** ScrambleIQ stack deployable in `app-hosting` via documented workflow.
- **Phase 6:** CI enforces formatting, validation, and change policy checks.
- **Phase 7:** Recovery drills demonstrate bounded RTO/RPO targets.
