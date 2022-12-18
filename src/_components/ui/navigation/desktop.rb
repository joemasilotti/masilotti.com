class Ui::Navigation::Desktop < SiteComponent
  attr_reader :current_path, :links

  def initialize(current_path:, links:)
    @current_path, @links = current_path, links
  end
end
