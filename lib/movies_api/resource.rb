# frozen_string_literal: true
module MoviesApi
  class Resource
    def initialize(attr = {})
      attr.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    end
  end
end
