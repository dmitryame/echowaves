class << ActiveRecord::Base
  def each(limit = 1000)
    # http://weblog.jamisbuck.org/2007/4/6/faking-cursors-in-activerecord
    rows = find(:all, :conditions => ["id > ?", 0], :limit => limit)

    while (rows.any?)
      rows.each { |record| yield record }
      last_id = rows.last.id
      rows = find(:all, :conditions => ["id > ?", last_id], :limit => limit)
    end

    # support method chaining
    self
  end
end
