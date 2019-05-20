require "epathway_scraper"

# Use current year if environment variable isn't set
ENV['MORPH_PERIOD'] ||= DateTime.now.year.to_s
puts "Getting data in year `" + ENV['MORPH_PERIOD'] + "`, changable via MORPH_PERIOD environment"

scraper = EpathwayScraper::Scraper.new("http://203.49.140.77/ePathway/Production")

page = scraper.pick_type_of_search(:all)

# a very bad and hackie way to collect DAs
# basically scan from DA 1 to whatever.... until 10 tries and assume it is 'The End'
i = 1
error = 0
while error < 10 do
  list = scraper.search_for_one_application(page, "DA-#{i}/#{ENV['MORPH_PERIOD']}")

  no_results = 0
  scraper.scrape_index_page(list) do |record|
    no_results += 1
    # The state was missing from the address
    record["address"] += ", NSW"
    EpathwayScraper.save(record)
  end
  if no_results > 0
    error = 0
  else
    error += 1
  end

  # increase i value and scan the next DA
  i += 1
end
