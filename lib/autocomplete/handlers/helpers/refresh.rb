module Autocomplete
  module Handlers
    module Helpers
      module Refresh

        def refresh!
          # assumption: assignment is atomic in ruby
          @cache = build_cache
          @last_refreshed_at = Time.now
        end

        def needs_refresh?
          return true if last_refreshed_at.nil?
          refresh_interval && last_refreshed_at + refresh_interval.minutes < Time.now
        end

        def refresh_interval
          @refresh_interval
        end

        def refresh_interval=(value)
          @refresh_interval = value
          @refresh_interval = @refresh_interval.to_i unless value.nil?
        end

        def last_refreshed_at
          @last_refreshed_at
        end

        def initialize_with_refresh_params(params = {})
          @refresh_interval = params.delete(:refresh_interval)
          initialize_without_refresh_params(params)
        end

        def self.include(klass)
          klass.alias_method_chain :initialize, :refresh_params
        end
      end
    end
  end
end
