# Migrate to Innovate – Azure + Red Hat Demo Package

This package contains **Bash scripts** and a **student guide (Markdown + Mermaid)** for the session:

**Migrate to Innovate: Building an AI-Ready Future with Red Hat and Microsoft**

It provisions:
- RHEL VM (legacy workload)
- Azure Red Hat OpenShift (ARO) cluster
- (Optional) Azure Arc onboarding (servers + Kubernetes)
- OpenShift Virtualization (CNV) on ARO
- A simple AI model service (Flask + scikit-learn) deployed to OpenShift
- Azure Monitor / Log Analytics integration (with OpenShift log forwarding)
- Microsoft Defender for Cloud / Sentinel enablement (baseline)
- Entra ID (Azure AD) integration scaffolding for ARO OAuth

> **Hands-off demo:** You can run these scripts to pre-build the environment and then present it. Students can later run the same steps themselves.

## Quick Start

1. **Install prerequisites** on your workstation:
   - Azure CLI (`az`) and log in: `az login`
   - OpenShift CLI (`oc`)
   - Ansible (optional for the RHEL step)
   - jq, envsubst (from `gettext`), and curl
2. **Edit `scripts/00_env.sh`** to set your desired region, names, and sizing.
3. Run scripts in order (idempotent where possible):
   ```bash
   cd scripts
   ./00_env.sh
   ./01_prereqs.sh
   ./02_network.sh
   ./03_rhel_vm.sh
   ./04_aro_cluster.sh
   # Optional/Advanced (after 04):
   ./05_arc_onboarding.sh
   ./06_aad_on_ocp.sh        # Requires 'oc login' to the new cluster
   ./07_ansible_demo.sh
   ./08_ocp_ai_deploy.sh
   ./09_openshift_virtualization.sh
   ./10_monitoring.sh
   ./11_defender_sentinel.sh
   # Cleanup when done
   ./12_cleanup.sh
   ```

The **student guide** at `student_guide.md` contains a 45‑minute walkthrough with diagrams and context.

> ⚠️ **Costs**: ARO clusters consume multiple VMs. Delete the resource group (`12_cleanup.sh`) when finished.
