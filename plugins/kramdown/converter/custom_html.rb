module Kramdown
  class Converter::CustomHtml < Converter::Html
    # Wrap rendered codeblocks to make them wider than prose.
    def convert_codeblock(el, indent)
      <<-HTML
      <div class="full-width">
        <div class="max-w-5xl mx-auto px-4 sm:px-12 lg:px-20">
          #{super}
        </div>
      </div>
      HTML
    end
  end
end
