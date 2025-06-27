module Jekyll
  module NumberFormattingFilter
    def round_to_nearest_100(input)
      input = input.to_i
      (((input + 50) / 100) * 100)
    end

    def with_commas(input)
      input.to_i.to_s.reverse.scan(/\d{1,3}/).join(",").reverse
    end

    def round_and_format(input)
      rounded = round_to_nearest_100(input)
      with_commas(rounded)
    end
  end
end

Liquid::Template.register_filter(Jekyll::NumberFormattingFilter)
