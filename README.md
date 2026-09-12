# Hugo Blog

A fast, minimalist blog and personal portfolio built with [Hugo](https://gohugo.io/) and the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme.

## Quick Start

You can use the provided `Makefile` or standard Hugo commands:

### 1. Local Development Server
```bash
make dev
# or: hugo server -D --bind 0.0.0.0
```
Open [http://localhost:1313](http://localhost:1313) in your browser.

### 2. Create a New Post
Use Hugo's leaf-bundle archetype to scaffold a new post directory:
```bash
make new-post slug=my-second-post
# or: hugo new content posts/my-second-post/index.md
```
The post will be created at `content/posts/my-second-post/index.md`. You can place images (e.g. `cover.png` or diagrams) directly in that folder and reference them relatively.

When ready to publish, set:
```toml
draft = false
```

### 3. Build for Production
Generate the optimized static site into `public/`:
```bash
make build
# or: hugo --gc --minify
```

### 4. Clean Build Artifacts
```bash
make clean
```

---

## Project Structure

```
├── .editorconfig                 # Code formatting standard
├── .github/workflows/deploy.yml  # GitHub Actions CI/CD deployment
├── Makefile                      # Standard automation commands
├── README.md                     # Documentation
├── archetypes/                   # Content templates
│   ├── default.md                # General pages
│   └── posts/index.md            # Blog post leaf bundle archetype
├── assets/
│   └── css/extended/custom.css   # Custom CSS overrides (PaperMod extension hook)
├── config/
│   └── _default/                 # Modular configuration directory
│       ├── hugo.toml             # Base site settings (URL, theme, pagination)
│       ├── params.toml           # Site parameters, social icons, search config
│       ├── menus.toml            # Header navigation menu definitions
│       └── markup.toml           # Goldmark markdown & Chroma syntax highlighting
├── content/                      # Site content
│   ├── posts/                    # Blog articles as Leaf Bundles
│   │   └── my-first-post/index.md
│   ├── about.md                  # About page
│   ├── archives.md               # Post archives
│   └── search.md                 # Instant search page
├── data/                         # Custom data files
├── layouts/                      # Custom Hugo layout overrides
├── static/                       # Static files served as-is
│   ├── profile/index.html        # Interactive terminal resume & profile
│   └── images/                   # Static global images
└── themes/PaperMod/              # Hugo PaperMod theme submodule
```

---

## Configuration

Site settings are modularized in `config/_default/`:
- **`hugo.toml`**: Site title, base URL, theme, pagination, and outputs.
- **`params.toml`**: Author metadata, social icons, home page intro, search settings.
- **`menus.toml`**: Header navigation items (`Posts`, `Archive`, `Tags`, `Search`, `Profile`, `About`).
- **`markup.toml`**: Markdown renderer rules and code syntax highlighting.
