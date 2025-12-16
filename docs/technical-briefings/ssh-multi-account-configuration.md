# SSH Multi-Account Configuration for GitHub

**Date**: 2025-12-16
**Audience**: CTO, DevOps, Engineering Leads
**Status**: Implemented
**Impact**: Critical (Enables secure multi-account GitHub operations)

---

## Executive Summary

Resolved SSH authentication issue preventing push to HuaQiao-Foundation organization repository. Root cause was SSH agent offering wrong key when multiple GitHub accounts are in use. Implemented configuration using `IdentitiesOnly yes` directive to ensure correct SSH key is used for each GitHub account.

**Key Outcomes**:
- Two GitHub accounts (brandomy, HuaQiao-admin) can be used simultaneously
- SSH configuration prevents key confusion
- Zero security compromise or credential exposure
- Repeatable pattern for future multi-account scenarios

---

## Problem Statement

### Initial Symptom

Git push to HuaQiao-Foundation/clubs repository failed with permission denied:

```bash
$ git push origin main
ERROR: Permission to HuaQiao-Foundation/clubs.git denied to brandomy.
fatal: Could not read from remote repository.
```

### Root Cause

When multiple SSH keys are loaded in the SSH agent, SSH offers all keys to the remote server. GitHub authenticates with the **first** matching key, not necessarily the one specified in SSH config. This caused authentication as the wrong GitHub account (brandomy instead of HuaQiao-admin).

**Technical Details**:
- Both SSH keys were loaded in SSH agent
- SSH agent takes precedence over `IdentityFile` directive in SSH config
- GitHub received brandomy's key first and authenticated as brandomy
- brandomy account couldn't push to HuaQiao-Foundation despite being an owner (likely due to repository not existing or permission settings)

---

## Solution Architecture

### SSH Configuration Pattern

```ssh
# GitHub - brandomy account (default)
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes          # ← Critical directive
    AddKeysToAgent yes
    UseKeychain yes

# HuaQiao-admin account
Host github-huaqiao
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_huaqiao
    IdentitiesOnly yes          # ← Critical directive
    AddKeysToAgent yes
    UseKeychain yes
```

### Key Directive: `IdentitiesOnly yes`

**Purpose**: Forces SSH to use **only** the specified `IdentityFile` and ignore all other keys in the SSH agent.

**Without this directive**:
- SSH tries all keys in the agent
- GitHub authenticates with the first matching key
- Wrong account is used

**With this directive**:
- SSH uses only the specified key file
- Correct account is guaranteed
- No key confusion possible

---

## Implementation Details

### Git Remote Configuration

**HuaQiao-Foundation repositories** use the `github-huaqiao` SSH host alias:

```bash
# apps/georgetown/.git/config
[remote "origin"]
    url = git@github-huaqiao:HuaQiao-Foundation/clubs.git
    fetch = +refs/heads/*:refs/remotes/origin/*
```

**Personal/brandomy repositories** use standard `github.com`:

```bash
# Example personal project
[remote "origin"]
    url = git@github.com:brandomy/my-project.git
    fetch = +refs/heads/*:refs/remotes/origin/*
```

### SSH Key Mapping

| Account | SSH Host | Key File | Key Location (GitHub) |
|---------|----------|----------|---------------------|
| brandomy | `github.com` | `~/.ssh/id_ed25519` | brandomy account SSH keys |
| HuaQiao-admin | `github-huaqiao` | `~/.ssh/id_huaqiao` | HuaQiao-admin account SSH keys |

### Verification Commands

**Test brandomy authentication**:
```bash
$ ssh -T git@github.com
Hi brandomy! You've successfully authenticated, but GitHub does not provide shell access.
```

**Test HuaQiao-admin authentication**:
```bash
$ ssh -T git@github-huaqiao
Hi HuaQiao-admin! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## Security Considerations

### SSH Key Management

**Best Practices Implemented**:
1. ✅ Separate SSH keys for each GitHub account
2. ✅ Keys use ED25519 algorithm (modern, secure)
3. ✅ Keys stored in `~/.ssh/` with proper permissions (600)
4. ✅ SSH config uses `IdentitiesOnly yes` to prevent key leakage
5. ✅ Keys added to SSH agent with macOS Keychain integration

**Security Benefits**:
- No key reuse across accounts
- Keys can be revoked independently
- SSH config prevents credential confusion
- No passwords or tokens in git config

### Organization Access Control

**Account Roles**:
- **brandomy**: Owner of HuaQiao-Foundation organization
- **HuaQiao-admin**: Owner of HuaQiao-Foundation organization

Both accounts have equivalent permissions but use separate identities for:
- Audit trail clarity
- Identity segregation
- Credential isolation

---

## Operational Impact

### Developer Workflow

**For HuaQiao-Foundation projects**:
```bash
# Clone using github-huaqiao host
$ git clone git@github-huaqiao:HuaQiao-Foundation/clubs.git

# Push/pull automatically uses HuaQiao-admin account
$ git push origin main
```

**For personal projects**:
```bash
# Clone using standard github.com
$ git clone git@github.com:brandomy/my-project.git

# Push/pull automatically uses brandomy account
$ git push origin main
```

### No Manual Key Management Required

Once SSH config is set up:
- No need to manually select keys
- No need to clear SSH agent
- No need to specify keys in git commands
- Authentication is automatic and correct

---

## Troubleshooting Guide

### Issue: "Permission denied to [wrong-account]"

**Diagnosis**:
```bash
# Check which account is authenticating
$ ssh -T git@github-huaqiao
Hi [account-name]! ...
```

**Solution**:
1. Verify `IdentitiesOnly yes` is in SSH config for that host
2. Verify correct key file is specified in `IdentityFile`
3. Clear SSH agent and re-test: `ssh-add -D && ssh-add ~/.ssh/id_huaqiao`

### Issue: "Key is already in use"

**Problem**: Trying to add SSH key to GitHub account when it's already registered on another account.

**Solution**:
1. Check which account has the key (test SSH connections)
2. Remove key from incorrect account
3. Add key to correct account

### Issue: Multiple keys in agent causing confusion

**Diagnosis**:
```bash
# List all keys in SSH agent
$ ssh-add -l
```

**Solution**:
- SSH config with `IdentitiesOnly yes` prevents this issue
- If issue persists, clear agent: `ssh-add -D`
- Re-add keys: `ssh-add ~/.ssh/id_ed25519 ~/.ssh/id_huaqiao`

---

## Scalability & Future Considerations

### Adding More GitHub Accounts

Pattern scales to any number of accounts:

```ssh
# Third account example
Host github-company
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_company
    IdentitiesOnly yes
    AddKeysToAgent yes
    UseKeychain yes
```

Then use `git@github-company:organization/repo.git` for that account.

### Team Adoption

**For teams with multiple accounts**:
1. Document SSH config pattern in team wiki
2. Provide template SSH config snippet
3. Include in onboarding documentation
4. Add to development environment setup scripts

### Alternative Approaches (Not Recommended)

**Deploy Keys**: Repository-specific keys, but limited to single repo
**Personal Access Tokens**: Works but less secure than SSH keys
**GitHub CLI**: Requires manual account switching

**Conclusion**: SSH config with `IdentitiesOnly yes` is the most robust solution.

---

## Technical Metrics

**Implementation Time**: 30 minutes
**Configuration Lines Changed**: 2 (added `IdentitiesOnly yes` to two hosts)
**Testing Time**: 5 minutes
**Documentation Time**: 20 minutes

**Risk Level**: Low (non-breaking change, backward compatible)
**Complexity**: Low (standard SSH configuration)
**Maintenance**: Zero (one-time setup)

---

## References

### SSH Configuration
- [OpenSSH Config Documentation](https://man.openbsd.org/ssh_config)
- [GitHub: Multiple SSH Keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys)
- [IdentitiesOnly Directive](https://man.openbsd.org/ssh_config#IdentitiesOnly)

### Related Documentation
- [Georgetown Automated Backups](automated-backup-solution.md)
- [SSH Troubleshooting Prompt](../prompts/2025-12-16-ssh-huaqiao-troubleshooting.md)
- [Georgetown Dev Journal](../../apps/georgetown/docs/dev-journal/)

---

## Recommendations for CTO

### Immediate Actions
1. ✅ Configuration implemented and tested
2. ✅ Documentation complete
3. ⏳ Review SSH key audit trail in GitHub organization settings
4. ⏳ Consider documenting this pattern in company infrastructure wiki

### Strategic Considerations

**Identity Management**:
- Current approach (separate personal accounts for org access) is functional
- For larger teams, consider GitHub Enterprise with SSO/SAML
- Document which account should be used for which repositories

**Security Posture**:
- Current setup follows SSH key best practices
- No secrets in repositories or git configs
- Keys can be rotated independently

**Scalability**:
- Pattern works for any number of accounts
- No performance impact
- Minimal maintenance overhead

### Future Enhancements (Optional)

**Short-term**:
- Document this pattern in team onboarding guide
- Add SSH config validation to development environment setup

**Long-term**:
- Evaluate GitHub Enterprise for centralized identity management
- Consider hardware security keys (YubiKey) for SSH authentication
- Implement SSH certificate authority if team grows significantly

---

## Conclusion

Successfully resolved SSH authentication issue through proper SSH configuration. The `IdentitiesOnly yes` directive ensures correct key usage for multi-account scenarios. Solution is production-ready, secure, and scales to additional accounts as needed.

**Status**: ✅ Complete
**Next Review**: No review needed (stable configuration)
**Support**: See troubleshooting guide above or contact DevOps

---

**Author**: Georgetown Development Team
**Date**: 2025-12-16
**Document Version**: 1.0
**Last Updated**: 2025-12-16
