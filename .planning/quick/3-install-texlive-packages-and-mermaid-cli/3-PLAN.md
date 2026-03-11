# Quick Task 3: Install texlive packages and mermaid-cli

**Task:** 3-install-texlive-packages-and-mermaid-cli  
**Created:** 2026-03-11  
**Mode:** quick

---

## Objective

Install LaTeX packages (lightweight set) and Mermaid CLI globally.

## Tasks

### Task 1: Install texlive packages

**Files:**
- `modules/50-tools/30-texlive.sh` (new module)

**Action:**
Create a module that installs texlive packages via apt:
1. Check if packages are already installed using `dpkg -l`
2. Install: texlive-latex-base, texlive-latex-recommended, texlive-latex-extra
3. Verify pdflatex is available

**Verify:**
- `dpkg -l | grep texlive` shows the three packages
- `which pdflatex` returns a path
- `pdflatex --version` works

**Done:**
All texlive packages installed.

---

### Task 2: Install mermaid-cli globally via npm

**Files:**
- `modules/50-tools/40-mermaid-cli.sh` (new module)

**Action:**
Create a module that installs @mermaid-js/mermaid-cli globally:
1. Check if mmdc is already installed
2. Verify npm is available (should be from Node.js installation)
3. Install globally: `npm install -g @mermaid-js/mermaid-cli`
4. Verify installation

**Verify:**
- `which mmdc` returns a path
- `mmdc --version` works

**Done:**
Mermaid CLI installed globally.

---

## Execution Order

1. Task 1 (texlive) - can run anytime
2. Task 2 (mermaid-cli) - requires npm from Node.js installation

## Notes

- All installations are idempotent
- Follows existing module patterns from modules/50-tools/
- Uses lib/common.sh for logging and error handling
