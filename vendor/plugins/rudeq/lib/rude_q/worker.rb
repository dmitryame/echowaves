# example worker class: lib/my_worker.rb
#   class MyWorker < RudeQ::Worker
#     def queue_name
#       :my_queue
#     end
#
#     def do_work(data)
#       MyMailer.send(data)
#     end
#   end
#
# example rake file: lib/tasks/worker.rake
#   namespace :worker do
#     desc "fire off a worker"
#     task :do => :environment do
#       worker = MyWorker.new
#       worker.do!
#     end
#   end
#
# then add a cron job to run "cd /path/to/wherever && rake worker:do RAILS_ENV=production"
module RudeQ
  class Worker

    def queue_name
      raise NotImplementedError
    end
    
    def do_work(data)
      raise NotImplementedError
    end
    
    def do!
      logger.info("starting up")
      if work = self.queue.get
        logger.info("found some work")
        do_work(work)
      else
        logger.info("couldn't find any work")
      end
      logger.info("finished for now")
    end      
  
    def logger
      unless @logger
        @logger = Logger.new(RAILS_ROOT + "/log/#{self.class.to_s.underscore}_#{RAILS_ENV}.log")
        class << @logger
          def format_message(severity, timestamp, progname, msg)
            "#{timestamp.strftime('%Y%m%d-%H:%M:%S')} (#{$$}) #{msg}\n"
          end
        end
      end
      return @logger
    end

    class << self
      def queue
        RudeQ::Scope.new(self.new.queue_name)
      end
    end

    def queue
      @queue ||= self.class.queue
    end
  end
end
