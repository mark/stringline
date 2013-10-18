module Stringline

  class Source

    ####################
    #                  #
    # Instance Methods #
    #                  #
    ####################

    def |(downstream)
      downstream.attach(self)
    end

    def more_content?
      raise NotImplementedError
    end

    def generate_content
      raise NotImplementedError
    end

    def receive
      fiber.resume
    end

    private

    def fiber
      @fiber ||= Fiber.new do
        while more_content?
          Fiber.yield generate_content
        end
        UpstreamFinished
      end
    end

  end

end
