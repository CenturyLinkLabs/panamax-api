module ArrayItemWrapper

  refine Array do
    def wrap(wrapper)
      map { |item| wrapper.new(item) }
    end
  end
end
