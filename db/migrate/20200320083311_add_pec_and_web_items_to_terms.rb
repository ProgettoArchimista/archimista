class AddPecAndWebItemsToTerms < ActiveRecord::Migration
  def change
    Term.connection.execute(
        "insert into terms (vocabulary_id, position, term_key, term_value, created_at, updated_at)
          select id, 4, 'pec', 'pec', SYSDATE(), SYSDATE()
          from vocabularies
          where name = 'custodian_contacts.contact_type'")

    Term.connection.execute(
        "insert into terms (vocabulary_id, position, term_key, term_value, created_at, updated_at)
          select id, 5, 'web', 'web', SYSDATE(), SYSDATE()
          from vocabularies
          where name = 'custodian_contacts.contact_type'")
  end
end
