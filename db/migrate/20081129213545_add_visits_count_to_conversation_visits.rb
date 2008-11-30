class AddVisitsCountToConversationVisits < ActiveRecord::Migration
  def self.up
    add_column :conversation_visits, :visits_count, :integer, :default => 1

    # remove duplicate entries from conversation_visits and combine into 1 entry
    @existing_data = ConversationVisit.all
    ConversationVisit.delete_all
    @existing_data.each do |r|
      if cv = ConversationVisit.find_by_user_id_and_conversation_id( r.user_id, r.conversation_id )
        cv.increment!( :visits_count )
      else
        ConversationVisit.create( :user_id => r.user_id, :conversation_id => r.conversation_id )
      end
    end

  end

  def self.down
    remove_column :conversation_visits, :visits_count
  end
end
