class SiteComponent < ViewComponent::Base
  # Must come before including Bridgetown View Component helpers.
  Bridgetown::ViewComponentHelpers.allow_rails_helpers :content_tag, :tag

  include Bridgetown::ViewComponentHelpers
end
