# Change Management

## Change Classes
- **Standard:** low-risk, pre-approved pattern with established rollback.
- **Normal:** planned change requiring review and scheduled execution window.
- **Emergency:** urgent remediation to restore security or service continuity.

## Required Change Record Content
- Problem statement and intent.
- Affected environments and services.
- Layer impact (provisioning/configuration/application).
- Validation plan and rollback plan.
- Dependency and ordering notes.

## Approval Rules
- At least one reviewer with infrastructure ownership must approve.
- Cross-layer changes require explicit acknowledgement of sequencing.
- Emergency changes require post-implementation retrospective and codification.

## Post-Change Requirements
- Capture validation evidence.
- Update decision log when architecture policy changes.
- Open follow-up actions for technical debt or unresolved risk.
