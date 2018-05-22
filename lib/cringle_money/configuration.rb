class CringleMoney
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :currencylayer_api_key

    def initialize
      @currencylayer_api_key = 'CURRENCYLAYER_API_KEY'
    end
  end
end
