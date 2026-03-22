# Ansible Playbooks

Executable playbooks that apply roles and tasks to infrastructure targets.

## Playbook Execution Layers
- `phase_1_test_core.yml`: Domain controller and Wazuh baseline deployment with endpoint telemetry validation.
- `caldera_deploy.yml`: Phase 3 Caldera deployment and prerequisite validation.
- `phase_3_detection_platform.yml`: End-to-end orchestration for Phase 2 baseline plus Phase 3 detection platform readiness.
- `security_enforcement.yml`: Phase 8 host hardening and policy enforcement convergence playbook.

