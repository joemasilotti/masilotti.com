require "bridgetown"

Bridgetown.load_tasks

task default: :deploy

desc "Build the Bridgetown site for deployment"
task deploy: [:clean, "frontend:build"] do
  Bridgetown::Commands::Build.start
end

desc "Runs the clean command"
task :clean do
  Bridgetown::Commands::Clean.start
end

namespace :frontend do
  desc "Build the frontend with esbuild for deployment"
  task :build do
    sh "touch frontend/styles/jit-refresh.css"
    sh "yarn run esbuild"
  end

  desc "Watch the frontend with esbuild during development"
  task :dev do
    sh "touch frontend/styles/jit-refresh.css"
    sh "yarn run esbuild-dev"
  rescue Interrupt
  end
end

namespace :og do
  desc "Download Open Graph images for all posts and newsletter editions"
  task download_all: :environment do
    site.process
    OpenGraph::Images.new(site:).download
  end

  desc "Download Open Graph image for a resource"
  task :download, [:resource_id] => :environment do |t, args|
    site.process
    OpenGraph::Image.new(args[:resource_id], site:).download
  end
end
