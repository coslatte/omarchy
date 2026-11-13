# Omarchy personal project

Repositorio contenedor para organizar los proyectos personales relacionados con Omarchy, manteniendo el historial y los remotos de cada componente mediante submódulos Git.

- `agents/`: reglas y agentes, repositorio `coslatte/agents`.
- `plugins/`: plugins personalizados de Omarchy, repositorio `coslatte/omarchy-plugins`.

Clona el proyecto y sus componentes con:

```bash
git clone --recurse-submodules git@github.com:coslatte/omarchy.git
```

Actualiza ambos submódulos desde sus ramas remotas con:

```bash
git submodule update --remote --merge
```
