module Workshop
  class CTA < SiteComponent
    attr_reader :newsletter

    def initialize(newsletter:, event_id:, hide_count: false)
      @newsletter, @event_id, @hide_count = newsletter, event_id, hide_count
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
      unless @hide_count
        "#{tickets} #{"ticket".pluralize(tickets)} remaining"
      end
    end

    private

    def tickets
      ENV.fetch("WORKSHOP_TICKETS_REMAINING").to_i
    end
  end
end
