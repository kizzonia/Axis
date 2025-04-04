# app/services/circuit_breaker.rb
class CircuitBreaker
  def initialize(service, max_failures: 3, timeout: 30.seconds)
    @service = service
    @max_failures = max_failures
    @timeout = timeout
    @failure_count = 0
    @last_failure_time = nil
  end

  def call
    if circuit_open?
      raise "Circuit open - #{@service.class.name} is unavailable"
    end

    result = @service.call
    reset_failures
    result
  rescue => e
    record_failure
    raise e
  end

  private

  def circuit_open?
    @failure_count >= @max_failures &&
    @last_failure_time &&
    (Time.current - @last_failure_time) < @timeout
  end

  def record_failure
    @failure_count += 1
    @last_failure_time = Time.current
  end

  def reset_failures
    @failure_count = 0
    @last_failure_time = nil
  end
end
