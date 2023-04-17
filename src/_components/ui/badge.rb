module UI
  class Badge < SiteComponent
    attr_reader :title, :color

    def initialize(title, color)
      @title = title
      @color = color
    end

    def class_names
      case @color&.to_sym
      when :pink
        "bg-pink-100 text-pink-800"
      when :primary
        "bg-primary-100 text-primary-800"
      end
    end
  end
end
