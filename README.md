# required functionality:
- Get exchange rates from one into one or more currencies
- Get value converted from one into one or more currencies
- Give the best rate and date over the last 7 days for a given currency pair

This Gem is build on top of the [money](https://rubygems.org/gems/money) gem. It implements a new bank (`Money::Bank`) `CurrencyLayerBank`,
which fetches current exchange rates from the [currencylayer API](https://currencylayer.com/documentation).

# Implemented APIs
- https://currencylayer.com/documentation

Locally add the API key to `ENV`: `export CURRENCYLAYER_API_KEY=YOUR_PRIVATE_KEY`

# build & install GEM locally
if previously built, remove gem file: `rm cringle_money-0.0.3.gem`
```
gem build cringle_money.gemspec
gem install cringle_money-0.0.3.gem
```

# Run via commandline:
```
irb
require 'cringle_money'
```
this should return:
`=> true`

now you can define any currencies using iso_codes:
```
from_currency = Money::Currency.wrap(:eur)
to_currency = Money::Currency.wrap(:usd)
to_currency2 = Money::Currency.wrap(:aud)
to_currencies = [to_currency, to_currency2]
```

define a date for which you wish to retrieve exchange rates

`exchange_date = Date.new(2018, 5, 20)`

Get exchange rates:

`CringleMoney.get_rates(from_currency, to_currencies, date: exchange_date)`

which will return:

`=> {"USD"=>1.177026, "AUD"=>1.564153}`

Get the best rate for the past 7 days via:

`CringleMoney.best_rate(from_currency, to_currency)`

which will return an array with one Date object and an exchange rate

`=> [#<Date: 2018-05-15 ((2458254j,0s,0n),+0s,2299161j)>, "1.182595"]`

Generate a CringleMoney object for any amount, e.g. 10 EUR (= 1.000 cents) and exchange it into any other currencies:
```
m = CringleMoney.new(1_000, 'EUR', date: exchange_date)
m.exchange_to(to_currencies)
```

which will return an array of CringleMoney objects (= Money object with an `exchange_date` property)

`=> [#<CringleMoney fractional:1177 currency:USD>, #<CringleMoney fractional:1564 currency:AUD>]`

(CringleMoney.fractional returns the value given in the currency's smallest unit, which is cents for EUR)
