require "epathway_scraper"

def is_valid_year(date_str, min=2000, max=DateTime.now.year)
  if ( date_str.scan(/^(\d)+$/) )
    if ( (min..max).include?(date_str.to_i) )
      return true
    end
  end
  return false
end

unless ( is_valid_year(ENV['MORPH_PERIOD'].to_s) )
  ENV['MORPH_PERIOD'] = DateTime.now.year.to_s
end
puts "Getting data in year `" + ENV['MORPH_PERIOD'].to_s + "`, changable via MORPH_PERIOD environment"

url         = 'http://203.49.140.77/ePathway/Production/Web'

scraper = EpathwayScraper::Scraper.new("http://203.49.140.77/ePathway/Production")

agent = Mechanize.new

page = scraper.pick_type_of_search(:all)

# a very bad and hackie way to collect DAs
# basically scan from DA 1 to whatever.... until 10 tries and assume it is 'The End'
i = 1
error = 0
cont = true
while cont do
  form = page.form
  form['ctl00$MainBodyContent$mGeneralEnquirySearchControl$mTabControl$ctl04$mFormattedNumberTextBox'] = 'DA-' + i.to_s + '/' + ENV['MORPH_PERIOD'].to_s
  form['ctl00$MainBodyContent$mGeneralEnquirySearchControl$mSearchButton'] ='Search'
  list = form.submit

  table = list.search("table.ContentPanel")
  unless ( table.empty? )
    error  = 0

    tr     = table.search("tr.ContentPanel")
    record = {
      'council_reference' => tr.search('a').inner_text,
      'address'           => tr.search('span')[1].inner_text + ', NSW',
      'description'       => tr.search('span')[0].inner_text.gsub("\n", '. ').squeeze(' '),
      'info_url'          => url + "/GeneralEnquiry/" + tr.search('a')[0]['href'],
      'date_scraped'      => Date.today.to_s,
      'date_received'     => Date.parse(tr.search('span')[2].inner_text).to_s,
    }

    puts "Saving record " + record['council_reference'] + ", " + record['address']
    # puts record
    ScraperWiki.save_sqlite(['council_reference'], record)
  else
    error += 1
  end

  # increase i value and scan the next DA
  i += 1
  if error == 10
    cont = false
  end
end
