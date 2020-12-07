class UpdateFeContexts < ActiveRecord::Migration
def up
    change_column :fe_contexts, :classification, :text, :limit => 16777215
    change_column :fe_contexts, :applicant, :text, :limit => 16777215
    change_column :fe_contexts, :request, :text, :limit => 16777215
  end
  def down
    change_column :fe_contexts, :classification, :text, :limit => 16777215
    change_column :fe_contexts, :applicant, :text, :limit => 16777215
    change_column :fe_contexts, :request, :text, :limit => 16777215
  end
end
