# RudeQ

# simply doing;
#   class RudeQueue < ActiveRecord::Base
#     include RudeQ
#   end
# will include RudeQ::ClassMethods
#   :get
#   :set
module RudeQ

  def self.included(mod) # :nodoc:
    mod.extend(ClassMethods)
    mod.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def data # :nodoc:
      YAML.load(self[:data])
    end
    def data=(value) # :nodoc:
      self[:data] = YAML.dump(value)
    end
  end

  module ClassMethods
    # Cleanup old processed items
    #
    #   RudeQueue.cleanup!
    #   RudeQueue.cleanup!(1.week)
    def cleanup!(expiry=1.hour)
      self.delete_all(["processed = ? AND updated_at < ?", true, expiry.to_i.ago])
    end
  
    # Add any serialize-able +data+ to the queue +queue_name+ (strings and symbols are treated the same)
    #   RudeQueue.set(:sausage_queue, Sausage.new(:sauce => "yummy"))
    #   RudeQueue.set("sausage_queue", Sausage.new(:other => true))
    #
    #   >> RudeQueue.get("sausage_queue")
    #   -> *yummy sausage*
    #   >> RudeQueue.get(:sausage_queue)
    #   -> *other_sausage*
    #   >> RudeQueue.get(:sausage_queue)
    #   -> nil
    def set(queue_name, data)
      queue_name = sanitize_queue_name(queue_name)

      self.create!(:queue_name => queue_name, :data => data)
      return nil # in line with Starling
    end

    # Grab the first item from the queue *queue_name* (strings and symbols are treated the same)
    #   - it should always come out the same as it went in
    #   - they should always come out in the same order they went in
    #   - it will return a nil if there is no unprocessed entry in the queue
    #
    #   >> RudeQueue.get(21)
    #   -> {:a => "hash"}
    #   >> RudeQueue.get(:a_symbol)
    #   -> 255
    #   >> RudeQueue.get("a string")
    #   -> nil
    def get(queue_name)
      qname = sanitize_queue_name(queue_name)
      
      fetch_with_lock(qname) do |record|
        if record
          processed!(record)
          return record.data
        else
          return nil # Starling waits indefinitely for a corresponding queue item
        end
      end
    end

    # Grab the first item from the queue, and execute the supplied block if there is one
    #   - it will return the value of the block
    #
    #   >> RudeQueue.fetch(:my_queue) do |data|
    #   >>   Monster.devour(data)
    #   >> end
    #   -> nil
    #
    #   >> status = RudeQueue.fetch(:my_queue) do |data|
    #   >>   process(data) # returns the value :update in this case
    #   >> end
    #   -> :update
    #   >> status
    #   -> :update
    def fetch(queue_name, &block)
      if data = get(queue_name)
        return block.call(data)
      end
    end

    # A snapshot count of unprocessed items for the given +queue_name+
    #
    #   >> RudeQueue.backlog
    #   -> 265
    #   >> RudeQueue.backlog(:one_queue)
    #   -> 212
    #   >> RudeQueue.backlog(:another_queue)
    #   -> 53
    #
    def backlog(queue_name=nil)
      conditions = {:processed => false}
      if queue_name
        conditions[:queue_name] = sanitize_queue_name(queue_name)
      end
      self.count(:conditions => conditions)
    end
    
    def fetch_with_lock(qname, &block) # :nodoc:
      lock = case queue_options[:lock]
      when :pessimistic then RudeQ::PessimisticLock
      when :token       then RudeQ::TokenLock
      else
        raise(ArgumentError, "bad queue_option for :lock - #{queue_options[:lock].inspect}")
      end
      lock.fetch_with_lock(self, qname, &block)
    end
    
    # class method to make it more easily stubbed
    def processed!(record) # :nodoc:
      case queue_options[:processed]
      when :set_flag
        record.update_attribute(:processed, true)
      when :destroy
        record.destroy
      else
        raise(ArgumentError, "bad queue_option for :processed - #{queue_options[:processed].inspect}")
      end
    end
    protected :processed!
    
    # configure your RudeQ
    # ==== :processed - what do we do after retrieving a queue item?
    # * <tt>:set_flag</tt> - set the +processed+ flag to +true+ (keep data in the db) [*default*]
    # * <tt>:destroy</tt>  - destroy the processed item (keep our queue as lean as possible
    #
    # ==== :lock - what locking method should we use?
    # * <tt>:pessimistic</tt> - RudeQ::PessimisticLock [*default*]
    # * <tt>:token</tt>       - RudeQ::TokenLock
    def queue_options
      @queue_options ||= {:processed => :set_flag, :lock => :pessimistic}
    end

    def data # :nodoc:
      YAML.load(self[:data])
    end
    def data=(value) # :nodoc:
      self[:data] = YAML.dump(value)
    end
    private
    
    def sanitize_queue_name(queue_name) # :nodoc:
      queue_name.to_s
    end
  end
  
  # uses standard ActiveRecord :lock => true
  # this will invoke a lock on the particular queue
  #   eg. daemon1: RudeQueue.get(:abc)
  #       daemon2: RudeQueue.get(:abc) - will have to wait for daemon1 to finish
  #       daemon3: RudeQueue.get(:def) - will avoid the lock
  module PessimisticLock
    class << self
      
      def fetch_with_lock(klass, qname) # :nodoc:
        klass.transaction do
          record = klass.find(:first,
            :conditions => {:queue_name => qname, :processed => false},
            :lock => true, :order => "id ASC", :limit => 1)
      
          return yield(record)
        end
      end
    
    end
  end
  
  # a crazy hack around database locking
  # that I thought was a good idea
  # turns out we can't make it use transactions properly
  # without creating a whole table lock
  # which misses the point
  #
  # also, it doesn't work on SQLite as it requires "UPDATE ... LIMIT 1 ORDER id ASC"
  # and as of RudeQueue2, you'll need to manually add the "token" column
  module TokenLock
    class << self
      
      require 'digest/sha1'
      
      def fetch_with_lock(klass, qname) # :nodoc:
        token = get_unique_token
        klass.update_all(["token = ?", token], ["queue_name = ? AND processed = ? AND token IS NULL", qname, false], :limit => 1, :order => "id ASC")
        record = klass.find_by_queue_name_and_token_and_processed(qname, token, false)
      
        return yield(record)
      end

      def token_count! # :nodoc:
        @token_count ||= 0
        @token_count += 1
        return @token_count
      end

      def get_unique_token # :nodoc:
        digest = Digest::SHA1.new
        digest << Time.now.to_s
        digest << Process.pid.to_s
        digest << Socket.gethostname
        digest << self.token_count!.to_s # multiple requests from the same pid in the same second get different token
        return digest.hexdigest
      end
    end
  end
end

