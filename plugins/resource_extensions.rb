module ResourceExtensions
  module RubyResource
    def formatted_date
      date.strftime("%B %e, %Y")
    end

    def series?
      data.series.present?
    end

    def back_href
      # TODO: Why can't I use url_for here?
      data.series_path || "/articles"
    end
  end
end

Bridgetown::Resource.register_extension ResourceExtensions
