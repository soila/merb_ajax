class Hash #:nodoc;
   # Return a new hash with all keys converted to symbols.
   def symbolize_keys
    inject({}) do |options, (key, value)|
      options[key.to_sym] = value
      options
    end
   end
end