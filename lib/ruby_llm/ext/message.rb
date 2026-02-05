module RubyLLM
  class Message
    def clear!
      clear_attachments!
      clear_thinking_signature!
    end

    def clear_attachments!
      @content.clear_attachments!
    end

    def clear_thinking_signature!
      thinking.try :clear_signature!
    end
  end
end
