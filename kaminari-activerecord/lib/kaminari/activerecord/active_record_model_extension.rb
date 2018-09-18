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

          Rails.logger.debug("per page: %i" % per_page)
          max_id = self.select("%s.id AS max_id" % self.table_name).order("id desc").limit(1)[0]["max_id"].to_i - (per_page * num.to_i)
          Rails.logger.debug("max id: %i" % max_id)
          min_id = max_id - per_page
          Rails.logger.debug("min id: %i" % min_id)


          limit(per_page).where("%s.id BETWEEN ? AND ?" % self.table_name, min_id, max_id).extending do
            include Kaminari::ActiveRecordRelationMethods
            include Kaminari::PageScopeMethods
          end
        end
      RUBY
    end
  end
end


# Card.select("id AS max_id").order("id desc").limit(1)[0]["max_id"]