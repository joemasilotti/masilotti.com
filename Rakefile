require "dotenv"
require "jekyll"
require "json"
require "net/http"
require "uri"

# bundle exec rake "generate_opengraph_images[/strada-launch]"
# bundle exec rake "generate_opengraph_images[/hotwire/1]"
desc "Generate an Open Graph image for a post via slug"
task :generate_opengraph_images, [:post_id] => :load_env do |t, args|
  post_id = args[:post_id]
  raise "Missing post_id" unless post_id

  config = Jekyll.configuration({})
  config["future"] = true
  site = Jekyll::Site.new(config)
  site.process

  find_post = proc do |collection|
    site.collections[collection].docs.find { |p| p.id == post_id || p.url == post_id }
  end

  post = find_post.call("posts") || find_post.call("hotwire") || find_post.call("hotwire_native") || find_post.call("newsletter")
  raise "Could not find post" unless post

  Image.new(post, site:).download
end

desc "Fetch Buttondown subscriber count and write to _data/subscriber_count.json"
task subscribers: :load_env do
  api_key = ENV["BUTTONDOWN_API_KEY"]
  abort("Missing BUTTONDOWN_API_KEY env var") unless api_key

  uri = URI("https://api.buttondown.email/v1/subscribers?type=regular")
  req = Net::HTTP::Get.new(uri)
  req["Authorization"] = "Token #{api_key}"

  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end

  unless res.is_a?(Net::HTTPSuccess)
    abort("Buttondown API request failed: #{res.code} #{res.message}")
  end

  body = JSON.parse(res.body)
  count = body["count"]

  data = { "count" => count }
  File.write("_data/subscribers.json", JSON.pretty_generate(data))

  puts "Wrote subscriber count: #{count}"
end

desc "Load environment variables from .env"
task :load_env do
  Dotenv.load unless ENV["GITHUB_ACTIONS"]
end
