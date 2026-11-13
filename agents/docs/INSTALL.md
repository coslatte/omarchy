# Instalación y recuperación en Arch Linux

Este kit copia instrucciones locales: **no instala automáticamente** software de terceros ni modifica tus credenciales. Revisa los repositorios y sus versiones antes de instalar.

## 1. Restaurar las reglas

```bash
unzip codex-agent-coordination-kit.zip
cd codex-agent-coordination-kit
bash scripts/install.sh
bash scripts/doctor.sh
```

El instalador no sobrescribe un Skill existente. Crea una copia de seguridad con timestamp de `~/.codex/AGENTS.md` si agrega el fragmento. Las reglas globales y el skill se conservan por separado. Para actualizar una instalación existente, compara los cambios con la versión del repositorio antes de sustituir archivos.

## 2. Agent Mesh

```bash
sudo pacman -S --needed git go make
mkdir -p ~/tools
git clone https://github.com/georgenijo/agent-mesh.git ~/tools/agent-mesh
cd ~/tools/agent-mesh
make build
export PATH="$PWD/bin:$PATH"
mesh up
mesh who
```

Para persistir el PATH, ajústalo en tu shell. La herramienta indica un dashboard local en `http://127.0.0.1:8737/ui/`. Usa `mesh --help` para comprobar flags y funciones de tu versión. **No presupongas que los subagentes nativos quedan registrados automáticamente.**

## 3. MCP Agent Mail

Repositorio: https://github.com/Dicklesworthstone/mcp_agent_mail_rust

Lee las instrucciones de instalación verificadas del repositorio y revisa scripts antes de ejecutarlos. El instalador oficial soporta Codex y configura MCP. Después, comprueba:

```bash
am setup status
am setup run --dry-run --project-dir "$PWD"
```

Arranca el servidor con `am` según la documentación. Con HTTP MCP en localhost, la configuración típica de Codex es:

```toml
[mcp_servers.mcp_agent_mail]
url = "http://127.0.0.1:8765/mcp/"
```

No sobrescribas `~/.codex/config.toml` entero. El instalador de Agent Mail puede incorporar autenticación; **no guardes tokens ni headers Authorization en este repositorio**. Usa su comando de setup para fusionar configuración autenticada. Comprueba herramientas desde Codex (`ensure_project`, `register_agent`, `file_reservation_paths`, `send_message`, `fetch_inbox`) y sus esquemas actuales.

## 4. Prueba segura

Crea un repositorio de prueba; no uses tu repositorio de empresa hasta comprobar acceso real al MCP, registro de agentes, reserva exclusiva, comunicación, worktrees aislados e integración local. Con agentes nativos que no pueden identificarse individualmente en MCP, la sesión padre debe mediar las reservas y la mensajería. Si fallan las conexiones, no hagas escrituras paralelas en archivos superpuestos.

## 5. Migrar a otra PC

Clona el repositorio privado de este kit, ejecuta `bash scripts/install.sh`, instala Mesh y Agent Mail según sus READMEs, configura autenticación local, ejecuta `bash scripts/doctor.sh` y verifica con Codex. Nunca exportes `~/.codex/auth.json`, claves, tokens, `.env` ni datos privados de Mesh/Agent Mail.
