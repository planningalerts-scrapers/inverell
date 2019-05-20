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
cont = true
while cont do
  form = page.form
  field = form.field_with(name: "ctl00$MainBodyContent$mGeneralEnquirySearchControl$mTabControl$ctl04$mFormattedNumberTextBox")
  field.value = 'DA-' + i.to_s + '/' + ENV['MORPH_PERIOD']
  button = form.button_with(value: "Search")
  list = form.submit(button)

  table = list.search("table.ContentPanel")

  unless ( table.empty? )
    error  = 0

    scraper.scrape_index_page(list) do |record|
      # The state was missing from the address
      record["address"] += ", NSW"
      EpathwayScraper.save(record)
    end
  else
    error += 1
  end

  # increase i value and scan the next DA
  i += 1
  if error == 10
    cont = false
  end
end
