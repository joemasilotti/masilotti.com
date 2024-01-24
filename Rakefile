require "jekyll"
require "dotenv"

# bundle exec rake "generate_opengraph_images[/strada-launch]"
# bundle exec rake "generate_opengraph_images[/hotwire/1]"
desc "Generate an Open Graph image for a post via slug"
task :generate_opengraph_images, [:post_id] do |t, args|
  post_id = args[:post_id]
  raise "Missing post_id" unless post_id

  config = Jekyll.configuration({})
  config["future"] = true
  site = Jekyll::Site.new(config)
  site.process

  find_post = proc do |collection|
    site.collections[collection].docs.find { |p| p.id == post_id || p.url == post_id }
  end

  post = find_post.call("posts") || find_post.call("hotwire")
  raise "Could not find post" unless post

  Dotenv.load
  Image.new(post, site:).download
end
