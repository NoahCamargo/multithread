require "multithread/version"
require 'multithread/list'

module Multithread
  class Error < StandardError; end
end

class ::Array
  def multi_each threads = 3, *args, &block
    Multithread::List.each(self, threads, *args, &block)
  end

  def multi_map threads = 3, *args, &block
    Multithread::List.map(self, threads, *args, &block)
  end
end