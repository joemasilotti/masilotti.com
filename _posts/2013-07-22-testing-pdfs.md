---
title: How to test PDFs with Capybara
date: 2013-07-22
description: Use familiar HTML testing tools to test drive PDF generation by combining wicked_pdf with some asset pipeline knowledge.
---

Validating that a web app's content is rendered correctly is an integral part of testing web apps. Displaying user-submitted input in HTML is the core functionality of almost any website. For example, the last couple of web sites you used most likely had you enter information in a text box that was later shown to you on another page.  A common way Rails developers achieve this is via [RSpec](https://github.com/rspec/rspec-rails) and [Capybara](https://github.com/jnicklas/capybara). Capybara provides [lots of matchers](http://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Matchers) to narrow down how to find elements on the page.

But what if you aren't displaying HTML to your users? What if the output is in a different format, like a PDF? **How do you validate PDF content using the standard RSpec and Capybara stack?**

### Invalid byte sequence in UTF-8?

Under one of my feature specs I attempted to call `page.should have_content('some content')` on a rendered PDF. Unfortunately, an error is thrown: `invalid byte sequence in UTF-8`. This error signals that the document contains invalid encoding. The problem could be a couple of unknown characters or that the document is missing an encoding type. Either way, Capybara needs a way to grab the actual contents in a format it can understand.

## `wicked_pdf`'s debug option

I used the [wicked_pdf](https://github.com/mileszs/wicked_pdf) gem to transform HTML/CSS pages to PDF via the [wkhtmltopdf](https://code.google.com/p/wkhtmltopdf/) shell utility. They have both been around for some time now and reliably render output using the Rails stack.

My first attempt to test content of a PDF used wicked_pdf's [debug](https://github.com/mileszs/wicked_pdf#debugging) option. By adding `:show_as_html => params[:debug].present?` to my rendering line I accessed the HTML (pre-PDF rendering) by appending `?debug=1` to my request. Now that the content was standard HTML Capybara's `page` worked normally.

However, the PDF may not line up with the HTML 100% using this method. This discrepancy causes problems when using complex CSS to render your pages; just because the spec passes via HTML doesn't guarantee the PDF will do the same. For example problems arise when using certain combinations of the `display:` property.

### Asset pipeline

How the accompanying CSS is referenced is another issue with this approach. Providing an absolute reference to any assets is required, since the wkhtmltopdf binary is [run outside of your Rails application](https://github.com/mileszs/wicked_pdf#usage-conditions---important). For example, a CSS file is referenced with the `wicked_pdf_stylesheet_link_tag "pdf"` helper method.

As a result, the HTML-rendered views grab CSS via a relative path while the PDF grabs CSS via an absolute path. While this is not an issue for a small app, this can become difficult to maintain once there are multiple CSS modules for different output formats.

## `PDF::Reader` to the rescue

A different approach is to leverage [pdf-reader](https://github.com/yob/pdf-reader)'s text rendering. You can then set the content of the Capybara `page` directly. First, render the PDF document and save it to a temporary local file. Then tell pdf-reader to parse the text to a standard format for Capybara to use. Finally, directly set Capybara's `@body` variable to the (now valid) PDF text contents.

```ruby
def convert_pdf_to_page
  temp_pdf = Tempfile.new('pdf')
  temp_pdf << page.source.force_encoding('UTF-8')
  reader = PDF::Reader.new(temp_pdf)
  pdf_text = reader.pages.map(&:text)
  page.driver.response.instance_variable_set('@body', pdf_text)
end
```

Once your page has loaded, call `convert_pdf_to_page` and use Capybara's `page` normally. All of the text matchers should work.

```ruby
page.should have_content('some PDF content')
```

Now the code stays succinct by using Capybara's built-in matchers for *both* HTML pages and PDF files. Now you don't need to worry about learning a new [DSL](https://en.wikipedia.org/wiki/Domain-specific_language) for PDF specs.

This post was heavily inspired by [Matthew O'Riordan's gist](https://gist.github.com/mattheworiordan/1200401). It uses an older version of pdf-reader so it needs to set up a bunch of manual string parsing to work. Lucky for us one of pdf-reader's [new API method](https://github.com/yob/pdf-reader/blob/master/lib/pdf/reader.rb#L68) now makes validating PDF content via Capybara much easier.

Check out the [full solution on GitHub](https://gist.github.com/joemasilotti/6045144).

## Improvements

- Move `convert_to_pdf` to `spec_helper.rb` to gain access to the helper method in all of your specs.
- Automatically convert PDF to text when the rendered content is detected as a PDF.
