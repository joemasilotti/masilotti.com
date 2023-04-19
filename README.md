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

Create a new file named `.env` and add the following to it:

```
WORKSHOP_PAYMENT_LINK=https://stripe.com
WORKSHOP_TICKETS_REMAINING=20
```

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

## Workshop tickets

When someone buys a ticket to the workshop:

1. Update the `WORKSHOP_TICKETS_REMAINING` [GitHub variable](https://github.com/joemasilotti/masilotti.com/settings/variables/actions) (not secret)
1. Click into the most recent successful [workflow](https://github.com/joemasilotti/masilotti.com/actions)
1. Click "Re-run all jobs"

Setting the variable to 0 will hide the payment link from the UI. It should also be [deactivated on Stripe](https://dashboard.stripe.com/payment-links) to ensure no one else can purchase a ticket.
