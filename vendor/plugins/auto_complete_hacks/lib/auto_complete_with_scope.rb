module AutoCompleteWithScope
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def auto_complete_with_scope_for(scopes, object, method, options = {})
      define_method("auto_complete_for_#{object}_#{method}") do
        find_options = { 
          :conditions => [ "LOWER(#{method}) LIKE ?", '%' + params[object][method].downcase + '%' ], 
          :order => "#{method} ASC",
          :limit => 10 }.merge!(options)
        
        @scope_proxy = object.to_s.camelize.constantize
        scopes.split('.').each do |scope|
          @scope_proxy = @scope_proxy.send(scope)
        end 
        
        @items = @scope_proxy.find(:all, find_options)
    
        render :inline => "<%= auto_complete_result @items, '#{method}' %>"
      end
    end
  end
end