require "epathway_scraper"

# Use current year if environment variable isn't set
ENV['MORPH_PERIOD'] ||= DateTime.now.year.to_s
year = ENV['MORPH_PERIOD'].to_i
puts "Getting data in year `#{year}`, changable via MORPH_PERIOD environment"

EpathwayScraper.scrape(
  "http://203.49.140.77/ePathway/Production",
  list_type: :all_year, year: year
) do |record|
  # The state was missing from the address
  record["address"] += ", NSW"
  EpathwayScraper.save(record)
end
