---
name: termux-proot-ssh-bridge
description: Instructions and command patterns for establishing an SSH bridge from proot-distro containers to native host Termux (127.0.0.1:8022) for live host testing, inspection, and verification.
---

# Termux Proot-to-Host SSH Bridge Skill

The **`termux-proot-ssh-bridge`** skill enables AI agents running inside `proot-distro` containers (such as Ubuntu on Termux) to execute commands on the native host Termux environment via SSH.

---

## Connection Protocol

### Target Parameters
- **Host**: `127.0.0.1` (Proot shares the host network namespace).
- **Port**: `8022` (Termux default `sshd` port).
- **Auth Key**: Stored in a temporary location (e.g. `/tmp/id_ed25519`).

### Key Permissions & Setup
```bash
chmod 600 /tmp/id_ed25519
```

---

## Execution Patterns

### 1. Test Host SSH Connection
```bash
ssh -i /tmp/id_ed25519 -p 8022 -o StrictHostKeyChecking=no 127.0.0.1 "id; uname -a"
```

### 2. Verify Hermes Executable & Version
```bash
ssh -i /tmp/id_ed25519 -p 8022 -o StrictHostKeyChecking=no 127.0.0.1 "export PATH=\$PATH:\$HOME/.local/bin:\$HOME/.hermes/hermes-agent/venv/bin; hermes --version"
```

### 3. Run Full Diagnostic Suite
```bash
ssh -i /tmp/id_ed25519 -p 8022 -o StrictHostKeyChecking=no 127.0.0.1 "export PATH=\$PATH:\$HOME/.local/bin:\$HOME/.hermes/hermes-agent/venv/bin; hermes doctor"
```

### 4. Execute Native Package Manager Operations
```bash
ssh -i /tmp/id_ed25519 -p 8022 -o StrictHostKeyChecking=no 127.0.0.1 "pkg install python-cryptography -y"
```

---

## Safety Rules for Agents
1. **Never Kill `sshd` Processes**: Refuse killing `sshd` processes on the host.
2. **Use Non-Interactive Flags**: Always include `-o StrictHostKeyChecking=no` and `-o ConnectTimeout=5` to prevent hanging interactive prompts.
3. **Clean Up Temporary Key Files**: Remove private keys from temporary locations after completing debugging sessions.
