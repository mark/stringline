module Stringline

  ##########
  #        #
  # Errors #
  #        #
  ##########

  class StringlineError < StandardError; end

  class UpstreamFailure < StringlineError; end

  #############
  #           #
  # Constants #
  #           #
  #############

  UpstreamFinished = Object.new

  require 'stringline/processor'
  require 'stringline/source'

end
