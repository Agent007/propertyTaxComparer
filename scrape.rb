require 'rubygems'
require 'mechanize'

agent = Mechanize.new

#page = agent.get('http://fultoncountytaxes.org/fultoniwr/11a_depts_property_taxes_results.asp?lstStreetType=ST&radPropertyType=RE&radSearchBy=Address&txtStreetName=West%20Peachtree&txtStreetNumber=400')
agent.get 'http://fultoncountytaxes.org/fultoniwr/11a_depts_property_taxes.asp'
agent.page.link_with(:text => 'Click here to start over').click
page = agent.page.link_with(:text => 'Search for a tax bill').click
form = page.form 'Search'
form.radiobuttons_with(:name => 'radSearchBy')[2].check
#form.lstStreetType = 'ST'
#form.radPropertyType = 'RE'
#form.radSearchBy = 'Address'
form.txtStreetName = 'West Peachtree'
form.txtStreetNumber = '400'
form.field_with(:name => 'lstStreetType').value = 'ST'
page = agent.submit(form)

parcel_id_xpath = "//a[contains(@href, 'Description.htm')]/../../../tr[2]/td[2]"
fair_market_value_xpath = "//a[contains(@href, 'FairMarketValue.htm')]/../../../tr[2]/td[3]"

excel_file = File.new('propertyTaxes.xls', 'w')

page.links_with(:text => /14 -0079-0013/).each do |link| # Alternatively, we can pre-load the parcel IDs instead of scraping them.
  unit_page = link.click
  excel_file.puts " " << unit_page.search(parcel_id_xpath).text.strip.delete('-') << "\t" << unit_page.search(fair_market_value_xpath).text.strip.delete(',')
end

form = page.form 'TaxSearch'
next_button = form.button_with(:value => '>> Next')

until nil == next_button do
  page = form.click_button next_button
  page.links_with(:text => /14 -0079-0013/).each do |link|
    unit_page = link.click
    excel_file.puts " " << unit_page.search(parcel_id_xpath).text.strip.delete('-') << "\t" << unit_page.search(fair_market_value_xpath).text.strip.delete(',')
  end
  form = page.form 'TaxSearch'
  next_button = form.button_with :value => '>> Next'
end
excel_file.close