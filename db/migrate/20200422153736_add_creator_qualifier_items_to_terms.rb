class AddCreatorQualifierItemsToTerms < ActiveRecord::Migration
  def change
    Term.connection.execute(
        "insert into terms (vocabulary_id, position, term_key, term_value, created_at, updated_at)
          select id, 5, 'intestazione', 'IN', SYSDATE(), SYSDATE()
          from vocabularies
          where name = 'creator_names.qualifier'")

    Term.connection.execute(
        "insert into terms (vocabulary_id, position, term_key, term_value, created_at, updated_at)
          select id, 6, 'patronimico', 'PT', SYSDATE(), SYSDATE()
          from vocabularies
          where name = 'creator_names.qualifier'")

    Term.connection.execute(
        "insert into terms (vocabulary_id, position, term_key, term_value, created_at, updated_at)
          select id, 7, 'pseudonimo', 'AL', SYSDATE(), SYSDATE()
          from vocabularies
          where name = 'creator_names.qualifier'")

    Term.connection.execute(
        "insert into terms (vocabulary_id, position, term_key, term_value, created_at, updated_at)
          select id, 7, 'soprannome', 'SN', SYSDATE(), SYSDATE()
          from vocabularies
          where name = 'creator_names.qualifier'")
  end
end
