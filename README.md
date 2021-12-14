# Masilotti.com, built with Jekyll and Tailwind CSS

This repo holds the code for [Masilotti.com](https://masilotti.com).

The site is built with Jekyll and styled with Tailwind CSS.

## Install

```bash
git clone git@github.com:joemasilotti/masilotti.com-tailwind masilotti.com
cd masilotti.com
bin/bootstrap
```

## Usage

```bash
# Start the server on http://localhost:3000
bin/start

# Create a new post
bin/new POST_TITLE
```

## Deploy

The GitHub Action deploys commits to `main` to `masilotti.com` via `rsync`. This is configured via the following GitHub Actions secrets.

```
REMOTE_HOST - the server to copy the code to
REMOTE_KEY - SSH key
REMOTE_KEY_PASS - password for SSH key
REMOTE_PATH - where the code is deployed on the server
REMOTE_USER - authenticated user for the SSH key
```
