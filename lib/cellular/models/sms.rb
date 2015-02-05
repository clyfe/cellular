module Cellular
  class SMS

    attr_accessor :recipient, :sender, :message, :price, :country_code
    attr_accessor :recipients
    def initialize(options = {})
      @backend = Cellular.config.backend

      @recipients = options[:recipients]
      @recipient = options[:recipient]
      @sender = options[:sender] || Cellular.config.sender
      @message = options[:message]
      @price = options[:price] || Cellular.config.price
      @country_code = options[:country_code] || Cellular.config.country_code

      @delivered = false
    end

    def deliver
      @delivery_status, @delivery_message = @backend.deliver options
      @delivered = true
    end

    def deliver_later
      Cellular::Jobs::AsyncMessenger.perform_async options
    end

    def deliver_at(timestamp)
      Cellular::Jobs::AsyncMessenger.perform_at timestamp, options
    end

    def save(options = {})
      raise NotImplementedError
    end

    def receive(options = {})
      raise NotImplementedError
    end

    def delivered?
      @delivered
    end

    def country
      warn "[DEPRECATION] 'country' is deprecated; use 'country_code' instead"
      @country_code
    end

    def country=(country)
      warn "[DEPRECATION] 'country' is deprecated; use 'country_code' instead"
      @country_code = country
    end

    private

    def options
      {
        recipients: @recipients,
        recipient: @recipient,
        sender: @sender,
        message: @message,
        price: @price,
        country_code: @country_code
      }
    end

  end
end
