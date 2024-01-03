require "digest"

# Adds a 6 character digest to the end of assets for long-lived caching.
class DigestFingerprinter < Liquid::Tag
  # {{ digest /assets/images/joe.jpg %}
  # {{ digest "/assets/images/joe-small.jpg" %}
  def initialize(tag_name, markup, tokens)
    super
    # Remove starting/trailing whitespace and quotes.
    @markup = markup.strip.gsub(/^"|^'|"$|'$/, "")
  end

  def render(context)
    filename = Liquid::Template.parse(@markup).render(context)
    sha256 = Digest::SHA256.file(
      File.join(context.registers[:site].dest, filename)
    )
    "#{filename}?#{sha256.hexdigest[0, 6]}"
  rescue Errno::ENOENT
    raise "File not found, cannot digest: #{filename} - #{@markup}"
  end
end

Liquid::Template.register_tag("digest", DigestFingerprinter)
