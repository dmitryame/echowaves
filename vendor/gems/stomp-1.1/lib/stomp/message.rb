module Stomp

  # Container class for frames, misnamed technically
  class Message
    attr_accessor :headers, :body, :command

    def initialize
      yield(self) if block_given?
    end

    def to_s
      "<Stomp::Message headers=#{headers.inspect} body='#{body}' command='#{command}' >"
    end
  end

end

