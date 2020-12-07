class UpdateDocumentForms < ActiveRecord::Migration
  def up
    change_column :document_forms, :name, :text, :limit => 16777215
    change_column :document_forms, :description, :text, :limit => 16777215
    change_column :document_forms, :note, :text, :limit => 16777215
  end
  def down
    change_column :document_forms, :name, :text, :limit => 16777215
    change_column :document_forms, :description, :text, :limit => 16777215
    change_column :document_forms, :note, :text, :limit => 16777215
  end
end
