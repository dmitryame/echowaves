module AutoCompleteWithScope
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def auto_complete_with_scope_for(scope, object, method, options = {})
      define_method("auto_complete_for_#{object}_#{method}") do
        find_options = { 
          :conditions => [ "LOWER(#{method}) LIKE ?", '%' + params[object][method].downcase + '%' ], 
          :order => "#{method} ASC",
          :limit => 10 }.merge!(options)
        
        @items = object.to_s.camelize.constantize.send(scope).find(:all, find_options)
    
        render :inline => "<%= auto_complete_result @items, '#{method}' %>"
      end
    end
  end
end