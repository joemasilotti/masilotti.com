# Masilotti.com, built with Jekyll

This repo holds the code for [Masilotti.com](https://masilotti.com).

## Requirements

* Ruby v3.2.2
* Node v16.2.0

## Usage

Start the server and visit [http://localhost:3000](http://localhost:3000).

When changes are saved the site will regenerate and reload any open pages in the browser.

Restart the server after changing the configuration file.

```bash
bundle exec jekyll server --livereload
```

## Deploy

The GitHub Action deploys `main` via `rsync`. This is configured via the following GitHub Actions secrets.

* `REMOTE_HOST`: The server to copy the code to.
* `REMOTE_KEY`: The SSH key.
* `REMOTE_KEY_PASS`: Password for SSH key.
* `REMOTE_PATH`: Where the code is deployed on the server.
* `REMOTE_USER`: Authenticated user for the SSH key.

## Best practices

* Posts live in the `_posts` directory and can be accessed via `site.posts`.
* Safely link to an post via `post_url`, referencing its date + title: `[My post]({% post_url 2024-01-01-my-post %})`
* Safely link to non-post pages via `link`, referencing the path, filename, and extension: `[Documentation]({% link _pages/documentation.liquid %})`
* Images for each posts live in their own directory, like so: `assets/images/my-post/`.

### Add a new series

Add new series to `_config.yml` _and_ `_data/series.yml`.

```ruby
# _config.yml

defaults:
  - scope:
      # Directory where the series lives.
      path: _posts/new-series/
      type: posts
    values:
      # Ensures posts in series are nested under name.
      permalink: /new-series/:title/
      # The root or intro page for the series. Optional.
      back: _posts/2024-01-01-new-series-intro.md
```

```ruby
# _data/series.yml
new-series:
  # Appears above each post's series title when rendered.
  title: A new series from Masilotti.com
```

In the post set the following front matter:
```
---
series: new-series
# Appears under title of series when rendered.
series_title: A deep dive into stuff
---
```

Finally, render the series navigation in the body of the post via `{% include series.liquid %}`.

## License

The content of this project itself is licensed under the [Creative Commons Attribution-NonCommercial 4.0 International license](https://creativecommons.org/licenses/by-nc/4.0/) and the underlying source code used to format and display that content is licensed under the [MIT license](LICENSE.md).
