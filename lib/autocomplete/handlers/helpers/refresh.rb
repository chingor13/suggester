module Autocomplete
  module Handlers
    module Helpers
      module Refresh

        def refresh!
          # assumption: assignment is atomic in ruby
          @cache = build_cache
          @last_refreshed_at = Time.now
        end

        def force_refresh!
          @last_refreshed_at = nil
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

      end
    end
  end
end
