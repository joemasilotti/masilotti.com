module Workshop
  class CTA < SiteComponent
    attr_reader :newsletter

    def initialize(newsletter:, event_id:)
      @newsletter, @event_id = newsletter, event_id
    end

    def event_id
      raise "Fathom event ID missing!" unless @event_id.present?
      @event_id
    end

    def href
      ENV.fetch("WORKSHOP_PAYMENT_LINK")
    end

    def available?
      tickets.positive?
    end

    def hero
      "#{tickets} #{"ticket".pluralize(tickets)} remaining"
    end

    private

    def tickets
      ENV.fetch("WORKSHOP_TICKETS_REMAINING").to_i
    end
  end
end
