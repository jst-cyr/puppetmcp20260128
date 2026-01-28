---
applyTo: '**'
---

# Puppet Development Instructions
Always use Puppet tools and MCP server for Puppet-related queries. Use PDK for development tasks, where possible. Do **not** scaffold modules by hand. Install PDK if it is missing.

**Puppet Module Development:**
- New module: `pdk new module <name>`
- Installing PDK: https://help.puppet.com/pdk/current/topics/pdk_install.htm
  **IMPORTANT: Always fetch and read the installation guide before attempting installation. PDK requires authentication (Puppet Core or PE credentials) and can no longer be installed via Chocolatey or Homebrew.**
  - **NEVER attempt to install PDK without first asking the user for credentials**
  
- Documentation: MCP tools (list_puppet_entities, get_puppet_entity_docs, get_puppet_guide)