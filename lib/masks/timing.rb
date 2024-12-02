module Masks
  class Timing
    def expired?(value)
      time =
        case value
        when String
          Time.parse(value)
        else
          value
        end

      time < Time.now.utc
    rescue TypeError, NoMethodError
      true
    end

    def min_time(delay)
      return yield unless delay && delay > 0

      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = yield
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      taken = (ending - starting).to_f * 1000
      min_ms = ([delay - taken, 0].max)
      sleep min_ms / 1000 if min_ms.nonzero?
      result
    end
  end
end
