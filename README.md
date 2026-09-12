# Hugo Blog

A fast, minimalist blog built with [Hugo](https://gohugo.io/) and the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme.

## Quick Start

### 1. Local Development Server
Start the embedded Hugo development server with live reload:

\\\ash
hugo server -D
\\\

Open [http://localhost:1313](http://localhost:1313) in your browser.

### 2. Create a New Post
Use Hugo's archetype generator to create a new post:

\\\ash
hugo new content posts/my-new-post.md
\\\

The file will be created in \content/posts/\ with front matter pre-populated from \rchetypes/default.md\.

When you are ready to publish, set:
\\\	oml
draft = false
\\\

### 3. Build for Production
Generate the static site into \public/\:

\\\ash
hugo --gc --minify
\\\

## Project Structure

\\\
├── archetypes/       # Content templates (front matter defaults)
│   └── default.md
├── assets/           # Raw assets (CSS/JS processed by Hugo pipes)
├── content/          # Markdown content pages and posts
│   ├── posts/        # Blog articles
│   ├── about.md      # About page
│   ├── archives.md   # Archive listing
│   └── search.md     # Client-side search page
├── hugo.toml         # Main site configuration
├── static/           # Static files copied as-is to public/ (favicon, images, etc.)
└── themes/PaperMod/  # Hugo PaperMod theme (Git submodule)
\\\

## Configuration
Edit \hugo.toml\ to update:
- Site title and base URL
- Author and social links
- Navigation menus
- Search and theme parameters
