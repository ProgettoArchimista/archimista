module TreeExt
  module ActsAsSequence
    module InstanceMethods

      def external_descendant_nodes(options={})
        external_nodes_class.external_descendant_nodes_for(self, options)
        #.additional_conditions(options[:conditions])
      end

      private

      def external_nodes_class
        self.class.external_nodes_class
      end

      def external_nodes_table
        external_nodes_class.table_name if external_nodes_class
      end

      def table_name
        self.class.table_name
      end

      def active_subtree_ids
# Upgrade 2.0.0 inizio
#        subtree.all(:select => 'id', :conditions => {:trashed => [false,nil]}).map{|rec| rec.id}
        subtree.select('id').where({:trashed => [false,nil]}).map{|rec| rec.id}
# Upgrade 2.0.0 fine
      end

      def trashed_subtree_ids
# Upgrade 2.0.0 inizio
#        subtree.all(:select => 'id', :conditions => {:trashed => true}).map{|rec| rec.id}
        subtree.select('id').where({:trashed => true}).map{|rec| rec.id}
# Upgrade 2.0.0 fine
      end

    end
  end
end

