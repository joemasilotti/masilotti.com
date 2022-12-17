class RodaApp < Bridgetown::Rack::Roda
  route do |r|
    r.bridgetown
  end
end
