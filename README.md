# Masilotti.com

This repo holds the code for [Masilotti.com](https://masilotti.com).

The site is built with [Bridgetown](https://www.bridgetownrb.com), a next-generation site generator powered by Ruby.

## Requirements

- [Ruby](https://www.ruby-lang.org/en/downloads/)
- [Node](https://nodejs.org)
- [Yarn](https://yarnpkg.com)

## Install

```bash
git clone git@github.com:joemasilotti/masilotti.com
cd masilotti.com
bundle install
yarn install
```

## Development

Start the server and navigate to [localhost:4000](https://localhost:4000/).

```bash
bin/bridgetown start
```

## Deployment

The GitHub Action copies builds the site then copies `output/` via `rsync` to a remote server. This is configured via the following actions secrets.

* `REMOTE_HOST` - Server to copy the code to
* `REMOTE_KEY` - SSH key
* `REMOTE_KEY_PASS` - Password for SSH key
* `REMOTE_PATH` - Where the code is deployed on the server
* `REMOTE_USER` - authenticated user for the SSH key
