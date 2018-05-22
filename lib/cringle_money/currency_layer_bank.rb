require 'http'
require 'redis'
require 'oj'

class Money
  module Bank
    # Thrown when an unknown rate format is requested.
    class UnknownRateFormat < StandardError; end
    class InvalidCache < StandardError; end

    class CurrencyLayerBank < Base

      def setup
        @redis = Redis.new(db: 5)
      end

      def clear_cached_rates
        @redis.flushdb
      end

      # returns decimal
      def get_rate(from_currency, to_currency, date = Date.today)
        get_rates(from_currency, [to_currency], date)[to_currency.iso_code]
      end

      # returns hash: { to_currency.iso_code => decimal }
      def get_rates(from_currency, to_currencies, date = Date.today)
        # Fetch cached rates from redis
        rates = to_currencies.map { |c| [c.iso_code, get_cached_rate(from_currency, c, date)] }.to_h
        rates_to_fetch = rates.select { |_, rate| rate.nil? || rate.to_f.zero? }.keys
        # Fetch missing rates to redis via one API call to CL
        cache_rates(from_currency, rates_to_fetch, date) unless rates_to_fetch.empty?
        # Fetch missing rates from redis
        rates_to_fetch.each { |c| rates[c] = get_cached_rate(from_currency, c, date) }
        rates
      end

      private

      def set_rate(from_currency, to_currency, rate, date)
        @redis.set(redis_key(from_currency, to_currency, date), rate)
      end

      # return currency exchange rate from cache as decimal
      def get_cached_rate(from_currency, to_currency, date)
        return 1.0 if from_currency == to_currency
        @redis.get(redis_key(from_currency, to_currency, date))
      end

      def cache_rates(from_currency, to_currencies, date)
        return if to_currencies&.empty? || to_currencies.nil?
        api_rates = historical_rates(from_currency, to_currencies, date)
        api_rates.each do |curr_pair, rate|
          from, to = curr_pair.scan(/.{3}/)
          set_rate(from, to, rate, date)
          # Cache reverse rate in order to reduce footprint of future requests
          set_rate(to, from, 1 / rate, date)
        end
      end

      def historical_rates(from_currency, to_currencies, date)
        new_rates = HTTP.get(historical_rates_request_url(from_currency, to_currencies, date))
        Oj.load(new_rates.body)['quotes']
      end

      def historical_rates_request_url(from_currency, to_currencies, date)
        URI::HTTP.build(
          host: 'apilayer.net',
          path: '/api/historical',
          query: {
            access_key: CringleMoney.configuration.currencylayer_api_key,
            source: from_currency,
            date: date.to_s,
            currencies: to_currencies.join(',')
          }.map { |k,v| "#{k}=#{v}" }.join('&')
        ).to_s
      end

      def redis_key(from, to, date)
        date = Date.parse(date) if date.is_a?(String)
        [from, to, date].join(':')
      end
    end
  end
end
