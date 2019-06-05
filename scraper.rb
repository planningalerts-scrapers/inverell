require "epathway_scraper"

EpathwayScraper.scrape_and_save(
  "http://203.49.140.77/ePathway/Production",
  list_type: :all_this_year, state: "NSW"
)
