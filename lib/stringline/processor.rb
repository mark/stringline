module Stringline

  class Processor

    ################
    #              #
    # Declarations #
    #              #
    ################

    attr_reader :upstream

    ####################
    #                  #
    # Instance Methods #
    #                  #
    ####################

    def |(downstream)
      downstream.attach(self)
    end

    def attach(upstream)
      @upstream = upstream
      self
    end

    def drain(into = [])
      loop do
        content = receive
        break if content == UpstreamFinished
        block_given? ? yield(content) : (into << content)
      end
      block_given? ? nil : into
    end

    def process(content)
      send_downstream content
    end

    def receive
      fiber.resume
    end

    # If you need to wrap the entire Stringline execution, override this:
    def run
      yield
    end

    private

    def fiber
      @fiber ||= Fiber.new do
        run do
          loop do
            content = upstream.receive

            break if content == UpstreamFinished
            received(content)
          end
        end
        UpstreamFinished
      end
    end

    def passing_errors_downstream(content)
      case content
      when StringlineError    then send_downstream(content)
      when UpstreamFinished then send_downstream(content)
                            else yield
      end
    rescue => e
      # Something happened to us, pass the error downstream
      #  as a Stringline::UpstreamFailure

      error = UpstreamFailure.new([self.inspect, e])
      send_downstream(error)
    end

    def received(content)
      passing_errors_downstream(content) do
        process(content)
      end
    end

    def send_downstream(response)
      Fiber.yield response
    end

  end

end
