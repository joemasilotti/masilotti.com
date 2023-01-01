source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "bridgetown", "1.2.0.beta4"

gem "bridgetown-feed"
gem "bridgetown-sitemap"
gem "bridgetown-svg-inliner"
gem "bridgetown-view-component"

# bridgetown-view-component doesn't work with 2.75+
gem "view_component", "< 2.75"

gem "dotenv"
gem "faraday"

group :development do
  gem "puma", "~> 5.6"
end
