module Workshop
  class CTA < SiteComponent
    DATE = Time.use_zone("Pacific Time (US & Canada)") do
      Time.zone.local(2023, 12, 5, 10)
    end

    attr_reader :newsletter

    def initialize(newsletter:, event_id:, hide_count: false)
      @newsletter, @event_id, @hide_count = newsletter, event_id, hide_count
    end

    def past_date?
      Date.today > DATE
    end

    def date
      end_time = (DATE + 2.hours).strftime("%l%P")
      DATE.strftime("%A, %B %e at %l%P-#{end_time} PT on Zoom | Cost: #{price} per person")
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

    def price
      "$149"
    end
  end
end
