require 'money'
require 'cringle_money/cringle_money'
require 'cringle_money/currency_layer_bank'
require 'cringle_money/configuration'

CringleMoney.configure do |config|
  config.currencylayer_api_key = ENV['CURRENCYLAYER_API_KEY']
end
