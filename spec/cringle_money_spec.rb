RSpec.describe CringleMoney do
  let(:from_currency) { Money::Currency.wrap(:eur) }
  let(:to_currency)   { Money::Currency.wrap(:usd) }
  let(:to_currency2)  { Money::Currency.wrap(:aud) }
  let(:rate_usd)      { 1.177026 }
  let(:rate_aud)      { 1.564153 }
  let(:rate_usd2)     { 1.177296 }
  let(:rate_usd3)     { 1.177296 }
  let(:rate_usd4)     { 1.179522 }
  let(:date)          { Date.new(2018, 5, 20) }
  let(:date2)         { Date.new(2018, 5, 19) }
  let(:date3)         { Date.new(2018, 5, 18) }
  let(:date4)         { Date.new(2018, 5, 17) }
  let(:bank)          { double('Money::Bank::CurrencyLayerBank.instance') }
  let(:cringle_money) { CringleMoney.new(1_000, 'EUR', bank, date: date) }

  describe '.get_rates' do
    before do
      allow(bank).to receive(:get_rates).with(from_currency, [to_currency], date).and_return('USD' => rate_usd)
      allow(bank).to receive(:get_rates).with(from_currency, [to_currency, to_currency2], date).and_return('USD' => rate_usd, 'AUD' => rate_aud)
    end

    context 'when converting to a single currency' do
      subject { CringleMoney.get_rates(from_currency, [to_currency], bank, date: date) }
      it { expect(subject).to eq('USD' => rate_usd) }
    end

    context 'when converting to multiple currencies' do
      subject { CringleMoney.get_rates(from_currency, [to_currency, to_currency2], bank, date: date) }
      it { expect(subject).to eq('USD' => rate_usd, 'AUD' => rate_aud) }
    end
  end

  describe '.best_rate' do
    before do
      allow(bank).to receive(:get_rate).with(from_currency, to_currency, date).and_return(rate_usd)
      allow(bank).to receive(:get_rate).with(from_currency, to_currency, date2).and_return(rate_usd2)
      allow(bank).to receive(:get_rate).with(from_currency, to_currency, date3).and_return(rate_usd3)
      allow(bank).to receive(:get_rate).with(from_currency, to_currency, date4).and_return(rate_usd4)
    end

    context 'when comparing 4 days' do
      subject { CringleMoney.best_rate(from_currency, to_currency, bank, range: date4..date) }
      it { expect(subject).to eq([date4, rate_usd4]) }
    end
  end

  describe '#exchange_to' do
    before do
      allow(bank).to receive(:get_rates).with(from_currency, [to_currency], date).and_return('USD' => rate_usd)
      allow(bank).to receive(:get_rates).with(from_currency, [to_currency, to_currency2], date).and_return('USD' => rate_usd, 'AUD' => rate_aud)
    end

    context 'when exchanging to a single currency' do
      subject { cringle_money.exchange_to(to_currency) }
      it { expect(subject.first.fractional).to eq(CringleMoney.new(1_177, 'USD').fractional) }
    end

    context 'when exchanging to multiple currencies' do
      subject { cringle_money.exchange_to([to_currency, to_currency2]) }
      it { expect(subject.count).to eq(2) }
      it { expect(subject.map { |m| [m.fractional, m.currency] }).to include([1_177, 'USD'], [1_564, 'AUD']) }
    end
  end
end
