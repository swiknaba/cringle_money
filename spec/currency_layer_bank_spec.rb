class MockBank < Money::Bank::CurrencyLayerBank
  def setup
    @redis = MockRedis.new(db: 3)
  end

  private

  def historical_rates(from_currency, to_currencies, _date)
    rates = { 'EURUSD' => 1.177026, 'EURAUD' => 1.564153 }
    rates.slice(*to_currencies.map { |c| [from_currency, c].join('') })
  end
end

RSpec.describe Money::Bank::CurrencyLayerBank do
  let!(:from_currency) { Money::Currency.wrap(:eur) }
  let!(:to_currency)   { Money::Currency.wrap(:usd) }
  let!(:to_currency2)  { Money::Currency.wrap(:aud) }
  let!(:date)          { Date.new(2018, 5, 20) }
  let!(:bank)          { MockBank.instance }

  before { bank.clear_cached_rates }

  describe '#get_rates' do
    context 'when fetching all rates via the api' do
      subject { bank.get_rates(from_currency, [to_currency], date) }
      it { expect(subject).to eq('USD' => '1.177026') }
    end

    # @NOTE what happens when the bank is called with iso currency codes vs Money::Currency objects.. how should it handle that
    context 'when fetching some rates from the cache and some via the api' do
      it { bank.send(:set_rate, from_currency, to_currency, 1.564153, date) }
      subject { bank.get_rates(from_currency, [to_currency, to_currency2], date) }
      it { expect(subject).to eq('USD' => '1.177026', 'AUD' => '1.564153') }
    end
  end

  describe '#get_rate' do
    context 'when fetching via API' do
      subject { bank.get_rate(from_currency, to_currency, date) }
      it { expect(subject).to eq('1.177026') }
    end

    context 'when fetching from cache' do
      it { bank.send(:set_rate, from_currency, to_currency, 1.564153, date) }
      subject { bank.get_rate(from_currency, to_currency, date) }
      it { expect(subject).to eq('1.177026') }
    end
  end
end
