class SiteBuilder < Bridgetown::Builder
  Bridgetown::Hooks.register :site, :post_write do |site|
    src_path = File.join(site.root_dir, "slides", "rails-world-2023")
    dest_path = File.join(site.root_dir, "output", "slides", "rails-world-2023")

    FileUtils.mkdir_p(File.dirname(dest_path))
    FileUtils.cp_r(src_path, dest_path)
  end
end
