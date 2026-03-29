#!/bin/bash
# Initialize CKS project structure
# Called by /cks:bootstrap and /cks:kickstart after CLAUDE.md is generated
# Creates: .prd/, .context/, .claude/settings.local.json, .env.example, .gitignore, .learnings/, README.md
# Optionally scaffolds project files (package.json, requirements.txt, directories) based on profile + stack

set -e

PROJECT_NAME="${1:-$(basename $(pwd))}"
PROJECT_DESC="${2:-}"
PROFILE="${3:-}"       # app | website | library | api (from bootstrap Q0)
SCAFFOLD_STACK="${4:-}" # nextjs | react | express | fastapi | django | flask | go | rust (from bootstrap scan)
TODAY=$(date +%Y-%m-%d)

echo "🔧 Initializing CKS project structure..."

# ============================================================
# DETECT PROJECT TYPE
# ============================================================
STACK="unknown"
DEV_CMD=""
BUILD_CMD=""
TEST_CMD=""

if [ -f "package.json" ]; then
  STACK="node"
  DEV_CMD=$(node -e "try{const p=require('./package.json');console.log(p.scripts?.dev||p.scripts?.start||'')}catch(e){}" 2>/dev/null)
  BUILD_CMD=$(node -e "try{const p=require('./package.json');console.log(p.scripts?.build||'')}catch(e){}" 2>/dev/null)
  TEST_CMD=$(node -e "try{const p=require('./package.json');console.log(p.scripts?.test||'')}catch(e){}" 2>/dev/null)
  # Detect framework
  grep -q '"next"' package.json 2>/dev/null && STACK="nextjs"
  grep -q '"react"' package.json 2>/dev/null && [ "$STACK" = "node" ] && STACK="react"
  grep -q '"vue"' package.json 2>/dev/null && STACK="vue"
  grep -q '"svelte"' package.json 2>/dev/null && STACK="svelte"
  grep -q '"express"' package.json 2>/dev/null && STACK="express"
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
  STACK="python"
  grep -q "django" requirements.txt pyproject.toml 2>/dev/null && STACK="django"
  grep -q "fastapi" requirements.txt pyproject.toml 2>/dev/null && STACK="fastapi"
  grep -q "flask" requirements.txt pyproject.toml 2>/dev/null && STACK="flask"
elif [ -f "Cargo.toml" ]; then
  STACK="rust"
elif [ -f "go.mod" ]; then
  STACK="go"
fi

echo "  Detected: $STACK"

# ============================================================
# PROJECT SCAFFOLDING (only when no source manifest exists)
# ============================================================
# If the project has no package.json/requirements.txt/etc AND a profile+stack
# were provided, create the project skeleton. Idempotent — skips if files exist.

HAS_MANIFEST=false
[ -f "package.json" ] || [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "Cargo.toml" ] || [ -f "go.mod" ] && HAS_MANIFEST=true

# Use SCAFFOLD_STACK if provided, fallback to detected STACK
SCAFFOLD="${SCAFFOLD_STACK:-$STACK}"

if [ "$HAS_MANIFEST" = false ] && [ -n "$PROFILE" ] && [ -n "$SCAFFOLD" ] && [ "$SCAFFOLD" != "unknown" ]; then
  echo ""
  echo "📦 Scaffolding project ($PROFILE / $SCAFFOLD)..."

  # --- Directory structure based on profile ---
  case "$PROFILE" in
    app)
      case "$SCAFFOLD" in
        nextjs)
          mkdir -p src/app src/components src/lib src/hooks src/types public
          echo "  ✅ Directories: src/{app,components,lib,hooks,types}, public/"
          ;;
        react)
          mkdir -p src/components src/hooks src/lib src/pages src/types public
          echo "  ✅ Directories: src/{components,hooks,lib,pages,types}, public/"
          ;;
        vue|svelte)
          mkdir -p src/components src/lib src/views src/stores public
          echo "  ✅ Directories: src/{components,lib,views,stores}, public/"
          ;;
        express|node)
          mkdir -p src/routes src/middleware src/services src/models src/lib tests
          echo "  ✅ Directories: src/{routes,middleware,services,models,lib}, tests/"
          ;;
        django)
          mkdir -p apps/ static/ templates/ tests/
          echo "  ✅ Directories: apps/, static/, templates/, tests/"
          ;;
        fastapi|flask)
          mkdir -p app/api app/models app/services app/schemas tests
          echo "  ✅ Directories: app/{api,models,services,schemas}, tests/"
          ;;
        go)
          mkdir -p cmd/ internal/ pkg/ api/
          echo "  ✅ Directories: cmd/, internal/, pkg/, api/"
          ;;
        rust)
          mkdir -p src/ tests/
          echo "  ✅ Directories: src/, tests/"
          ;;
      esac
      ;;
    website)
      case "$SCAFFOLD" in
        nextjs)
          mkdir -p src/app src/components src/lib public/images
          echo "  ✅ Directories: src/{app,components,lib}, public/images/"
          ;;
        react|vue|svelte)
          mkdir -p src/components src/pages src/assets public
          echo "  ✅ Directories: src/{components,pages,assets}, public/"
          ;;
        *)
          mkdir -p src/ public/images public/css public/js
          echo "  ✅ Directories: src/, public/{images,css,js}"
          ;;
      esac
      ;;
    api)
      case "$SCAFFOLD" in
        nextjs|express|node)
          mkdir -p src/api src/middleware src/services src/models src/lib src/types tests
          echo "  ✅ Directories: src/{api,middleware,services,models,lib,types}, tests/"
          ;;
        fastapi|flask|django)
          mkdir -p app/api app/models app/services app/schemas app/middleware tests
          echo "  ✅ Directories: app/{api,models,services,schemas,middleware}, tests/"
          ;;
        go)
          mkdir -p cmd/server/ internal/handler/ internal/service/ internal/model/ pkg/ api/
          echo "  ✅ Directories: cmd/server/, internal/{handler,service,model}, pkg/, api/"
          ;;
        rust)
          mkdir -p src/api src/models src/services tests/
          echo "  ✅ Directories: src/{api,models,services}, tests/"
          ;;
      esac
      ;;
    library)
      case "$SCAFFOLD" in
        node|nextjs|react|vue|svelte|express)
          mkdir -p src/ tests/ examples/
          echo "  ✅ Directories: src/, tests/, examples/"
          ;;
        python|django|fastapi|flask)
          mkdir -p src/"$PROJECT_NAME" tests/ examples/
          echo "  ✅ Directories: src/$PROJECT_NAME/, tests/, examples/"
          ;;
        go)
          mkdir -p pkg/ internal/ examples/
          echo "  ✅ Directories: pkg/, internal/, examples/"
          ;;
        rust)
          mkdir -p src/ tests/ examples/
          echo "  ✅ Directories: src/, tests/, examples/"
          ;;
      esac
      ;;
  esac

  # --- Package manifest based on stack ---
  case "$SCAFFOLD" in
    nextjs)
      if [ ! -f "package.json" ]; then
        cat > package.json << PKGEOF
{
  "name": "$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "vitest"
  },
  "dependencies": {
    "next": "^15",
    "react": "^19",
    "react-dom": "^19"
  },
  "devDependencies": {
    "@types/node": "^22",
    "@types/react": "^19",
    "typescript": "^5",
    "vitest": "^3"
  }
}
PKGEOF
        echo "  ✅ package.json (Next.js)"
      fi
      if [ ! -f "tsconfig.json" ]; then
        cat > tsconfig.json << TSEOF
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
TSEOF
        echo "  ✅ tsconfig.json"
      fi
      ;;
    react)
      if [ ! -f "package.json" ]; then
        cat > package.json << PKGEOF
{
  "name": "$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest"
  },
  "dependencies": {
    "react": "^19",
    "react-dom": "^19"
  },
  "devDependencies": {
    "@types/react": "^19",
    "@types/react-dom": "^19",
    "@vitejs/plugin-react": "^4",
    "typescript": "^5",
    "vite": "^6",
    "vitest": "^3"
  }
}
PKGEOF
        echo "  ✅ package.json (React + Vite)"
      fi
      ;;
    vue|svelte)
      if [ ! -f "package.json" ]; then
        cat > package.json << PKGEOF
{
  "name": "$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test": "vitest"
  },
  "devDependencies": {
    "vite": "^6",
    "vitest": "^3"
  }
}
PKGEOF
        echo "  ✅ package.json ($SCAFFOLD + Vite — add $SCAFFOLD dependency via npm install)"
      fi
      ;;
    express|node)
      if [ ! -f "package.json" ]; then
        cat > package.json << PKGEOF
{
  "name": "$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest"
  },
  "dependencies": {
    "express": "^5"
  },
  "devDependencies": {
    "@types/express": "^5",
    "@types/node": "^22",
    "tsx": "^4",
    "typescript": "^5",
    "vitest": "^3"
  }
}
PKGEOF
        echo "  ✅ package.json (Express)"
      fi
      ;;
    fastapi)
      if [ ! -f "requirements.txt" ]; then
        cat > requirements.txt << REQEOF
fastapi>=0.115
uvicorn[standard]>=0.34
pydantic>=2.0
python-dotenv>=1.0
REQEOF
        echo "  ✅ requirements.txt (FastAPI)"
      fi
      if [ ! -f "pyproject.toml" ]; then
        cat > pyproject.toml << PYEOF
[project]
name = "$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
version = "0.1.0"
requires-python = ">=3.11"

[tool.pytest.ini_options]
testpaths = ["tests"]
PYEOF
        echo "  ✅ pyproject.toml"
      fi
      ;;
    django)
      if [ ! -f "requirements.txt" ]; then
        cat > requirements.txt << REQEOF
django>=5.1
python-dotenv>=1.0
django-cors-headers>=4.0
REQEOF
        echo "  ✅ requirements.txt (Django)"
      fi
      ;;
    flask)
      if [ ! -f "requirements.txt" ]; then
        cat > requirements.txt << REQEOF
flask>=3.1
python-dotenv>=1.0
REQEOF
        echo "  ✅ requirements.txt (Flask)"
      fi
      ;;
    go)
      if [ ! -f "go.mod" ]; then
        GO_MODULE="github.com/$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
        cat > go.mod << GOEOF
module $GO_MODULE

go 1.23
GOEOF
        echo "  ✅ go.mod"
      fi
      ;;
    rust)
      if [ ! -f "Cargo.toml" ]; then
        cat > Cargo.toml << RUSTEOF
[package]
name = "$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
version = "0.1.0"
edition = "2024"
RUSTEOF
        echo "  ✅ Cargo.toml"
      fi
      ;;
  esac

  # Re-detect stack after scaffolding (for gitignore and README later)
  if [ -f "package.json" ]; then
    STACK="node"
    grep -q '"next"' package.json 2>/dev/null && STACK="nextjs"
    grep -q '"react"' package.json 2>/dev/null && [ "$STACK" = "node" ] && STACK="react"
    grep -q '"vue"' package.json 2>/dev/null && STACK="vue"
    grep -q '"svelte"' package.json 2>/dev/null && STACK="svelte"
    grep -q '"express"' package.json 2>/dev/null && STACK="express"
  elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    STACK="python"
    grep -q "django" requirements.txt pyproject.toml 2>/dev/null && STACK="django"
    grep -q "fastapi" requirements.txt pyproject.toml 2>/dev/null && STACK="fastapi"
    grep -q "flask" requirements.txt pyproject.toml 2>/dev/null && STACK="flask"
  elif [ -f "Cargo.toml" ]; then
    STACK="rust"
  elif [ -f "go.mod" ]; then
    STACK="go"
  fi
else
  if [ "$HAS_MANIFEST" = true ]; then
    echo "  ⏭  Project manifest exists — skipping scaffolding"
  elif [ -z "$PROFILE" ]; then
    echo "  ⏭  No profile provided — skipping scaffolding"
  fi
fi

# ============================================================
# .prd/
# ============================================================
mkdir -p .prd

if [ ! -f ".prd/PRD-STATE.md" ]; then
  # Detect if kickstart ran
  KICKSTART_STATUS="not_started"
  KICKSTART_DATE="—"
  if [ -f ".kickstart/state.md" ]; then
    KICKSTART_LAST=$(grep "last_phase:" .kickstart/state.md 2>/dev/null | sed 's/.*: *//' | xargs)
    if [ "$KICKSTART_LAST" = "complete" ]; then
      KICKSTART_STATUS="complete"
      KICKSTART_DATE="$TODAY"
    else
      KICKSTART_STATUS="in_progress"
    fi
  fi

  cat > .prd/PRD-STATE.md << PRDEOF
# PRD Session State

**Last Updated:** $TODAY

## Kickstart Status

- **Kickstart Phase:** —
- **Kickstart Status:** $KICKSTART_STATUS
- **Kickstart Date:** $KICKSTART_DATE

## Current Position

- **Active Phase:** —
- **Phase Name:** —
- **Phase Status:** idle
- **Last Action:** Project bootstrapped
- **Last Action Date:** $TODAY
- **Next Action:** Start first feature
- **Suggested Command:** /cks:new

## Feature History

| PRD | Feature | Phases | Status |
|-----|---------|--------|--------|

## Working Notes

_Auto-captured by CKS session hooks. Persists context across sessions._

| Date | Branch | Files Changed | Key Activity |
|------|--------|---------------|-------------|

## Session History

| Date | Phase | Action | Result |
|------|-------|--------|--------|
| $TODAY | — | Bootstrap | CKS initialized |
PRDEOF
  echo "  ✅ .prd/PRD-STATE.md"
else
  echo "  ⏭  .prd/PRD-STATE.md (exists)"
fi

if [ ! -f ".prd/PRD-PROJECT.md" ]; then
  cat > .prd/PRD-PROJECT.md << PRDEOF
# Project: $PROJECT_NAME

**Bootstrapped:** $TODAY
**Stack:** $STACK

## Context

See CLAUDE.md for full project context, stack details, and conventions.
PRDEOF
  echo "  ✅ .prd/PRD-PROJECT.md"
else
  echo "  ⏭  .prd/PRD-PROJECT.md (exists)"
fi

if [ ! -f ".prd/PRD-ROADMAP.md" ]; then
  cat > .prd/PRD-ROADMAP.md << PRDEOF
# Roadmap

**Project:** $PROJECT_NAME
**Last Updated:** $TODAY

## Active Features

| # | Feature | Status | Phases |
|---|---------|--------|--------|

## Completed Features

| # | Feature | Completed | Phases |
|---|---------|-----------|--------|
PRDEOF
  echo "  ✅ .prd/PRD-ROADMAP.md"
else
  echo "  ⏭  .prd/PRD-ROADMAP.md (exists)"
fi

# ============================================================
# .context/config.md
# ============================================================
mkdir -p .context

if [ ! -f ".context/config.md" ]; then
  SITES=""
  if [ -f "package.json" ]; then
    grep -q '"next"' package.json 2>/dev/null && SITES="${SITES}\n  - nextjs.org/docs"
    grep -q '"react"' package.json 2>/dev/null && SITES="${SITES}\n  - react.dev"
    grep -q '"supabase"' package.json 2>/dev/null && SITES="${SITES}\n  - supabase.com/docs"
    grep -q '"stripe"' package.json 2>/dev/null && SITES="${SITES}\n  - docs.stripe.com"
    grep -q '"tailwind"' package.json 2>/dev/null && SITES="${SITES}\n  - tailwindcss.com/docs"
    grep -q '"prisma"' package.json 2>/dev/null && SITES="${SITES}\n  - prisma.io/docs"
    grep -q '"drizzle"' package.json 2>/dev/null && SITES="${SITES}\n  - orm.drizzle.team/docs"
    grep -q '"@clerk"' package.json 2>/dev/null && SITES="${SITES}\n  - clerk.com/docs"
    grep -q '"firebase"' package.json 2>/dev/null && SITES="${SITES}\n  - firebase.google.com/docs"
    grep -q '"vue"' package.json 2>/dev/null && SITES="${SITES}\n  - vuejs.org/guide"
    grep -q '"svelte"' package.json 2>/dev/null && SITES="${SITES}\n  - svelte.dev/docs"
    grep -q '"@angular"' package.json 2>/dev/null && SITES="${SITES}\n  - angular.dev/guide"
    grep -q '"mongoose"' package.json 2>/dev/null && SITES="${SITES}\n  - mongoosejs.com/docs"
    grep -q '"@auth"' package.json 2>/dev/null && SITES="${SITES}\n  - authjs.dev"
    grep -q '"resend"' package.json 2>/dev/null && SITES="${SITES}\n  - resend.com/docs"
    grep -q '"shadcn"' package.json 2>/dev/null && SITES="${SITES}\n  - ui.shadcn.com"
  fi
  if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    grep -q "django" requirements.txt pyproject.toml 2>/dev/null && SITES="${SITES}\n  - docs.djangoproject.com"
    grep -q "fastapi" requirements.txt pyproject.toml 2>/dev/null && SITES="${SITES}\n  - fastapi.tiangolo.com"
    grep -q "flask" requirements.txt pyproject.toml 2>/dev/null && SITES="${SITES}\n  - flask.palletsprojects.com"
    grep -q "sqlalchemy" requirements.txt pyproject.toml 2>/dev/null && SITES="${SITES}\n  - docs.sqlalchemy.org"
  fi
  if [ -f "Cargo.toml" ]; then
    SITES="${SITES}\n  - doc.rust-lang.org/book"
  fi
  if [ -f "go.mod" ]; then
    SITES="${SITES}\n  - pkg.go.dev"
  fi

  # Use printf to handle \n properly
  printf -- "---\nsources:\n  - context7\n  - firecrawl\n  - websearch\n  - webfetch\nauto-research: true\nmax-lines: 200\npreferred-sites:${SITES}\n---\n# Context Research Config — generated by /cks:bootstrap\n" > .context/config.md
  echo "  ✅ .context/config.md"
else
  echo "  ⏭  .context/config.md (exists)"
fi

# ============================================================
# .env.example
# ============================================================
if [ ! -f ".env.example" ]; then
  ENV_VARS=""

  # Node.js projects
  if [ -f "package.json" ]; then
    ENV_VARS=$(grep -roh 'process\.env\.\w\+\|import\.meta\.env\.\w\+' src/ app/ lib/ pages/ components/ server/ 2>/dev/null | sed 's/process\.env\.//;s/import\.meta\.env\.//' | sort -u)
  fi

  # Python projects
  if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    PY_VARS=$(grep -roh 'os\.environ\[.\([^]]*\).\]\|os\.environ\.get(.\([^)]*\).\)\|os\.getenv(.\([^)]*\).\)' . --include="*.py" 2>/dev/null | sed "s/os\.environ\[//;s/os\.environ\.get(//;s/os\.getenv(//;s/['\"\])]*//g" | sort -u)
    ENV_VARS="${ENV_VARS}${PY_VARS:+\n$PY_VARS}"
  fi

  # Also check .env files for existing vars
  if [ -f ".env" ] || [ -f ".env.local" ] || [ -f ".env.development" ]; then
    EXISTING=$(cat .env .env.local .env.development 2>/dev/null | grep -v '^#' | grep -v '^$' | cut -d= -f1 | sort -u)
    ENV_VARS="${ENV_VARS}${EXISTING:+\n$EXISTING}"
  fi

  # Deduplicate
  ENV_VARS=$(printf "%b" "$ENV_VARS" | sort -u | grep -v '^$')

  if [ -n "$ENV_VARS" ]; then
    {
      echo "# $PROJECT_NAME — Environment Variables"
      echo "# Copy to .env.local and fill in values"
      echo ""
      echo "$ENV_VARS" | while IFS= read -r var; do
        [ -n "$var" ] && echo "$var="
      done
    } > .env.example
    VAR_COUNT=$(echo "$ENV_VARS" | wc -l | tr -d ' ')
    echo "  ✅ .env.example ($VAR_COUNT vars)"
  else
    {
      echo "# $PROJECT_NAME — Environment Variables"
      echo "# Copy to .env.local and fill in values"
      echo ""
      echo "# Add your environment variables here"
    } > .env.example
    echo "  ✅ .env.example (template — no vars detected)"
  fi
else
  echo "  ⏭  .env.example (exists)"
fi

# ============================================================
# .gitignore
# ============================================================
if [ -f ".gitignore" ]; then
  ADDED=0
  # Check and add missing entries
  grep -qx "\.env" .gitignore 2>/dev/null || grep -q "^\.env$" .gitignore 2>/dev/null || { echo ".env" >> .gitignore; ADDED=$((ADDED+1)); }
  grep -q "\.env\.local" .gitignore 2>/dev/null || { echo ".env.local" >> .gitignore; ADDED=$((ADDED+1)); }
  grep -q "\.env\.\*" .gitignore 2>/dev/null || grep -q "\.env\.production" .gitignore 2>/dev/null || { echo ".env.*" >> .gitignore; ADDED=$((ADDED+1)); }
  grep -q "!\.env\.example" .gitignore 2>/dev/null || { echo "!.env.example" >> .gitignore; ADDED=$((ADDED+1)); }
  grep -q "\.DS_Store" .gitignore 2>/dev/null || { echo ".DS_Store" >> .gitignore; ADDED=$((ADDED+1)); }

  if [ $ADDED -gt 0 ]; then
    echo "  ✅ .gitignore ($ADDED entries added)"
  else
    echo "  ⏭  .gitignore (already configured)"
  fi
else
  # Create stack-appropriate .gitignore
  {
    echo "# Dependencies"
    case "$STACK" in
      node|nextjs|react|vue|svelte|express)
        echo "node_modules/"
        echo ".next/"
        echo "dist/"
        echo "build/"
        echo ".turbo/"
        ;;
      python|django|fastapi|flask)
        echo "__pycache__/"
        echo "*.pyc"
        echo ".venv/"
        echo "venv/"
        echo "*.egg-info/"
        echo "dist/"
        ;;
      rust)
        echo "target/"
        ;;
      go)
        echo "bin/"
        echo "vendor/"
        ;;
    esac
    echo ""
    echo "# Environment"
    echo ".env"
    echo ".env.local"
    echo ".env.*"
    echo "!.env.example"
    echo ""
    echo "# OS"
    echo ".DS_Store"
    echo "Thumbs.db"
    echo ""
    echo "# IDE"
    echo ".vscode/"
    echo ".idea/"
    echo "*.swp"
    echo "*.swo"
  } > .gitignore
  echo "  ✅ .gitignore (created for $STACK)"
fi

# ============================================================
# .claude/settings.local.json (Agent Teams + project settings)
# ============================================================
mkdir -p .claude

if [ ! -f ".claude/settings.local.json" ]; then
  cat > .claude/settings.local.json << 'SETTINGSEOF'
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "teammateMode": "auto"
}
SETTINGSEOF
  echo "  ✅ .claude/settings.local.json (agent teams enabled)"
else
  # Ensure agent teams env var is present in existing settings
  if ! grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" .claude/settings.local.json 2>/dev/null; then
    # Use node/python to merge JSON if available, otherwise warn
    if command -v node &>/dev/null; then
      node -e "
        const fs = require('fs');
        const s = JSON.parse(fs.readFileSync('.claude/settings.local.json','utf8'));
        s.env = s.env || {};
        s.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = '1';
        s.teammateMode = s.teammateMode || 'auto';
        fs.writeFileSync('.claude/settings.local.json', JSON.stringify(s, null, 2) + '\n');
      "
      echo "  ✅ .claude/settings.local.json (agent teams added to existing)"
    else
      echo "  ⚠️  .claude/settings.local.json exists but missing CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS — add manually"
    fi
  else
    echo "  ⏭  .claude/settings.local.json (agent teams already enabled)"
  fi
fi

# ============================================================
# .learnings/
# ============================================================
mkdir -p .learnings
echo "  ✅ .learnings/ (ready for /cks:retro)"

# ============================================================
# README.md
# ============================================================
if [ ! -f "README.md" ]; then
  # Detect run commands for README
  [ -z "$DEV_CMD" ] && DEV_CMD="npm run dev"
  [ -z "$BUILD_CMD" ] && BUILD_CMD="npm run build"

  {
    echo "# $PROJECT_NAME"
    echo ""
    if [ -n "$PROJECT_DESC" ]; then
      echo "$PROJECT_DESC"
      echo ""
    fi
    echo "## Getting Started"
    echo ""
    echo "### Prerequisites"
    echo ""
    case "$STACK" in
      node|nextjs|react|vue|svelte|express)
        echo "- Node.js 18+"
        echo "- npm or pnpm"
        ;;
      python|django|fastapi|flask)
        echo "- Python 3.10+"
        echo "- pip or poetry"
        ;;
      rust)
        echo "- Rust (latest stable)"
        ;;
      go)
        echo "- Go 1.21+"
        ;;
      *)
        echo "- See project dependencies"
        ;;
    esac
    echo ""
    echo "### Setup"
    echo ""
    echo '```bash'
    echo "# Clone the repo"
    echo "git clone $(git remote get-url origin 2>/dev/null || echo 'https://github.com/your-org/your-repo.git')"
    echo "cd $(basename $(pwd))"
    echo ""
    echo "# Install dependencies"
    case "$STACK" in
      node|nextjs|react|vue|svelte|express)
        echo "npm install"
        ;;
      python|django|fastapi|flask)
        echo "pip install -r requirements.txt"
        ;;
      rust)
        echo "cargo build"
        ;;
      go)
        echo "go mod download"
        ;;
    esac
    echo ""
    echo "# Set up environment"
    echo "cp .env.example .env.local"
    echo "# Fill in your environment variables"
    echo ""
    echo "# Run development server"
    case "$STACK" in
      node|nextjs|react|vue|svelte|express)
        echo "npm run dev"
        ;;
      django)
        echo "python manage.py runserver"
        ;;
      fastapi)
        echo "uvicorn main:app --reload"
        ;;
      flask)
        echo "flask run --debug"
        ;;
      rust)
        echo "cargo run"
        ;;
      go)
        echo "go run ."
        ;;
    esac
    echo '```'
    echo ""
    echo "## Environment Variables"
    echo ""
    echo "Copy \`.env.example\` to \`.env.local\` and fill in the values."
    echo ""
    echo "## Development"
    echo ""
    echo "This project uses [CKS](https://github.com/cardinalconseils/claude-starter) for AI-assisted development."
    echo ""
    echo '```bash'
    echo "/cks:go dev        # Start dev server"
    echo "/cks:go            # Build + commit + push + PR"
    echo "/cks:new           # Plan a new feature"
    echo "/cks:ship          # Full ship ceremony"
    echo "/cks:help          # All commands"
    echo '```'
  } > README.md
  echo "  ✅ README.md"
else
  echo "  ⏭  README.md (exists)"
fi

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CKS project structure initialized"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Files:"
[ -f "CLAUDE.md" ] && echo "    CLAUDE.md"
[ -f "README.md" ] && echo "    README.md"
[ -f ".env.example" ] && echo "    .env.example"
[ -f ".gitignore" ] && echo "    .gitignore"
ls -1 .prd/ 2>/dev/null | sed 's/^/    .prd\//'
ls -1 .context/ 2>/dev/null | sed 's/^/    .context\//'
[ -f ".claude/settings.local.json" ] && echo "    .claude/settings.local.json"
echo "    .learnings/"
echo ""
echo "  Next steps:"
echo "    /cks:new \"brief\"   Define features + create phases"
echo "    /cks:go dev        Start dev server"
echo "    /cks:help          See all commands"
