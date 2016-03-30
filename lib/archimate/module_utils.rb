module Archimate
  module ModuleUtils

# Upgrade 2.0.0 inizio
    # merge_conditions is a deprecated ActiveRecord::Base method from rails 2.3.8
    # questo e' il codice della funzione merge_conditions() di ActiveRecord 2.3.17
    def misc_merge_conditions(*conditions)
      segments = []

      conditions.each do |condition|
        unless condition.blank?
          sql = sanitize_sql(condition)
          segments << sql unless sql.blank?
        end
      end

      "(#{segments.join(') AND (')})" unless segments.empty?
    end

    def misc_log_message(message, level = "info")
      case level
        when "debug"
          Rails.logger.debug message
        when "info"
          Rails.logger.info message
        when "warn"
          Rails.logger.warn message
        when "error"
          Rails.logger.error message
        when "fatal"
          Rails.logger.fatal message
        else
          Rails.logger.info message
      end
      puts message
    end
# Upgrade 2.0.0 fine

    private

    def override_defaults(options={})
      options.each_pair do |option, value|
        new_value = value.instance_of?(Array) ? [value].flatten : value
        send("#{option}=", new_value)
      end
    end

  end
end

