module RubyLLM
  class Content
    def clear_attachments!
      @attachments = []

      if @text.is_a?(Hash)
        @text[:attachments] = []
      end
    end
  end
end
