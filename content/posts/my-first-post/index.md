+++
title = 'Welcome to My Hugo Blog'
date = '2026-09-12T14:22:45Z'
draft = false
author = "Siva"
description = "Getting started with Hugo and the PaperMod theme."
tags = ["hugo", "static-site", "web-development"]
categories = ["Tech"]
showToc = true
TocOpen = true
+++

## Introduction

Welcome to my new static site powered by **[Hugo](https://gohugo.io/)** and the **[PaperMod](https://github.com/adityatelange/hugo-PaperMod)** theme!

Hugo is an extraordinarily fast open-source static site generator written in Go. It turns markdown files and templates into complete, production-ready static HTML pages in milliseconds.

## Why Hugo?

- **Blazing Fast**: Builds pages in milliseconds.
- **Easy Maintenance**: Content is written in standard Markdown (`.md`).
- **Flexible & Lightweight**: Zero external database or complex backend required.
- **Modern Themes**: Clean, responsive, dark/light mode, and mobile-friendly layouts out of the box.

## Code Highlighting Example

Here is a quick example of code highlighting with Chroma:

```bash
# Start Hugo local development server with drafts enabled
hugo server -D

# Build the static site for production
hugo --gc --minify
```

And in Python:

```python
def greet(name: str) -> str:
    """Return a warm greeting."""
    return f"Hello, {name}! Welcome to Hugo."

print(greet("Developer"))
```

## Next Steps

1. Create new posts using:
   ```bash
   hugo new content posts/my-second-post.md
   ```
2. Customize `hugo.toml` to adjust theme colors, menus, and author profile.
3. Deploy to GitHub Pages, Netlify, Cloudflare Pages, or Vercel!
