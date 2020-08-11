require "multithread/version"
require 'multithread/array'

module Multithread
  class Error < StandardError; end
end

class Array
  def multi_each threads = 3, *args, &block
    MultiThread::Array.each(self, threads, *args, &block)
  end

  def multi_map threads = 3, *args, &block
    MultiThread::Array.map(self, threads, *args, &block)
  end
end