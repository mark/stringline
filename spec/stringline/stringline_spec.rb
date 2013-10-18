require 'spec_helper'

class SampleSource < Stringline::Source

  def initialize(strings)
    @strings = strings
  end

  def more_content?
    @strings.any?
  end

  def generate_content
    @strings.shift
  end

end

class UpcaseProcessor < Stringline::Processor

  def process(content)
    send_downstream content.upcase
  end

end

class ReverseProcessor < Stringline::Processor

  def process(content)
    send_downstream content.reverse
  end

end

class DoublingProcessor < Stringline::Processor

  def process(content)
    2.times { send_downstream(content) }
  end

end

class WrappingProcessor < Stringline::Processor

  def run
    send_downstream "BEFORE"
    yield
    send_downstream "AFTER"
  end

end

describe "Stringlines" do

  let(:source)  { SampleSource.new %w(foo bar baz quux) }
  let(:upcase)  { UpcaseProcessor.new                   }
  let(:reverse) { ReverseProcessor.new                  }
  let(:wrapper) { WrappingProcessor.new                 }

  describe "A complete stringline" do

    subject { source | upcase | reverse }

    it "receives the modified words in order" do
      subject.drain.must_equal %w(OOF RAB ZAB XUUQ)
    end

  end

  describe "Using #run to get around the records" do

    subject { source | wrapper }

    it "provides a way to perform setup and teardown behavior" do
      subject.drain.must_equal %w(BEFORE foo bar baz quux AFTER)
    end

  end


end
