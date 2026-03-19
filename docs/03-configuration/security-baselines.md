# Security Baselines

## Security Baseline Objectives
- Enforce least privilege and auditable access.
- Standardize host hardening and service exposure.
- Support detection and response validation in roadmap phases 3-4.

## Required Controls
- Role-based administrative access with traceable identity.
- Default-deny host/network policies with explicit service allows.
- Centralized event forwarding to Wazuh.
- Time synchronization for event correlation integrity.
- Service hardening according to documented role policy.

## Security Validation Integration
- Prometheus/Grafana monitor service health and baseline drift signals.
- Caldera exercises verify visibility and detection pathways.
- Findings are fed into change-management and decision-log updates.

## Baseline Drift Policy
- Drift detected by telemetry or audits must be remediated via Ansible role updates.
- Emergency manual mitigations must be codified post-incident before closure.
