class CringleMoney < Money
  attr_reader :exchange_date

  class << self
    # input: to_currencies needs to be an array of currency_codes
    def get_rates(from_currency, to_currencies, bank = Money::Bank::CurrencyLayerBank.instance, date: Date.today)
      to_currencies = to_currencies.map { |c| Money::Currency.wrap(c) }
      from_currency = Money::Currency.wrap(from_currency)
      bank.get_rates(from_currency, to_currencies, date)
    end

    def best_rate(from_currency, to_currency, bank = Money::Bank::CurrencyLayerBank.instance, range: (Date.today - 7)..Date.today)
      # Note: On the Pro plan, we'd use the timeframe queries ( up to 365 day ). Implementing via separate API calls for as I don't have a Pro plan.
      range.map{ |date| [date, bank.get_rate(from_currency, to_currency, date)] }.to_h.max_by{ |k,v| v.to_f }
    end
  end

  def initialize(obj, currency, bank = Money::Bank::CurrencyLayerBank.instance, date: nil)
    super(obj, currency, bank)
    self.exchange_date = date || Date.today
  end

  def exchange_to(other_currencies)
    other_currencies = [*other_currencies].map { |c| Money::Currency.wrap(c) }
    rates = bank.get_rates(self.currency, other_currencies, self.exchange_date)
    rates.map do |currency_code, rate|
      CringleMoney.new(fractional * rate.to_f, currency_code, date: exchange_date)
    end
  end

  def exchange_date=(date)
    @exchange_date = Date.parse(date.to_s)
  end
end
