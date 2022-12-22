class Bridgetown::Converters::Markdown::CustomMarkdownProcessor
  def initialize(config)
    @config = config
  end

  def convert(content)
    Kramdown::Document.new(content, @config["kramdown"]).to_custom_html
  end
end
