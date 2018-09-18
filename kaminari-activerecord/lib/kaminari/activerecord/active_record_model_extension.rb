# frozen_string_literal: true
require 'kaminari/activerecord/active_record_relation_methods'

module Kaminari
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    included do
      include Kaminari::ConfigurationMethods

      # Fetch the values at the specified page number
      #   Model.page(5)
      eval <<-RUBY, nil, __FILE__, __LINE__ + 1
        def self.#{Kaminari.config.page_method_name}(num = nil)
          per_page = max_per_page && (default_per_page > max_per_page) ? max_per_page : default_per_page
          max_id = self.select("{self.table_name}.id AS max_id").order("id desc").limit(1)[0]["max_id"] - (per_page * num.to_i)

          min_id = (per_page * 2) * num.to_i #


          limit(per_page).where("#{self.table_name}.id BETWEEN ? AND ?", max_id, min_id).extending do
            include Kaminari::ActiveRecordRelationMethods
            include Kaminari::PageScopeMethods
          end
        end
      RUBY
    end
  end
end
