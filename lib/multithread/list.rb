module Multithread
  class List
    class << self
      def each list, threads = 3, allow_error: true, messages: true, error: "Multithread.each:", &block
        run(list, threads, allow_error, error, false, messages, block)
        return list
      end
  
      def map list, threads = 3, allow_error: true, messages: true, error: "Multithread.map:", &block
        run(list, threads, allow_error, error, true, messages, block)
      end
  
      protected
      def run list, threads, allow_error, error, allow_return, messages, block
        return list unless block
  
        init_threads! threads
  
        results = [] if allow_return
  
        list.each_with_index do |item, i|
          current_index = find_thread messages
  
          @threads[current_index] = Thread.new do
            Rails.application.executor.wrap do
              begin
                allow_return ? results << [i, block.(item, i)] : block.(item, i)
              rescue => e
                allow_error ? error!(error, e) : warning!(error, e)
              end
            end
  
            if @main_thread.status == 'sleep' || !!@main_thread.status
              @thread_index = current_index unless @thread_index
              @main_thread.run
            end
          end
        end
  
        @threads.each(&:join)
        finished_threads!
  
        allow_return ? results.sort.to_h.values : results
      rescue SystemExit, Interrupt, IRB::Abort => e
        warning!(error, e)
  
        @threads.each(&:exit)
        finished_threads!
      end
  
      def create_threads slots
        Array.new(slots < 0 ? 1 : slots).map { Thread.new{} }.each(&:join)
      end
  
      def find_thread messages = true
        thread_index = nil
  
        loop do
          printf "\rProcessing items... total_thread: #{Thread.list.count} - thread_index: #{@threads.map(&:status).join(', ')}#{(' ' * 10)}" if messages
  
          if @thread_index
            @threads[thread_index = @thread_index].join
            @thread_index = nil
          else
            @threads.each_with_index { |thread, i| if !thread.status then thread_index = i; break end }
          end
  
          thread_index.nil? ? sleep(10) : break
        end
  
        thread_index
      end
  
      def init_threads! threads
        @thread_index = 0
        @threads      = create_threads(threads)
        @main_thread  = Thread.current
      end
  
      def finished_threads!; @thread_index = @threads = @main_thread = nil end
      def warning! message, error; puts("\e[1;33mWARNING:\e[0m #{message} #{error}") end
      def error! message, error; raise("\n\e[1;31mERROR:\e[0m #{message} #{error}") end
    end
  end
end
