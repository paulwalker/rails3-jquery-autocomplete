module Rails3JQueryAutocomplete
  module Orm
    module Mongoid
      def mongoid_get_autocomplete_order(method, options, model=nil)
        order = options[:order]
        if order
          order.split(',').collect do |fields|
            sfields = fields.split
            [sfields[0].downcase.to_sym, sfields[1].downcase.to_sym]
          end
        else
          [[method.to_sym, :asc]]
        end
      end

      def mongoid_get_autocomplete_items(parameters)
        model          = parameters[:model]
        method         = parameters[:method]
        options        = parameters[:options]
        class_method   = options[:class_method]
        is_full_search = options[:full]
        term           = parameters[:term]
        limit          = get_autocomplete_limit(options)
        order          = mongoid_get_autocomplete_order(method, options)

        if is_full_search
          search = '.*' + Regexp.escape(term) + '.*'
        else
          search = '^' + Regexp.escape(term)
        end
        search = Regexp.new(search, true)
        query = if class_method
          model.send(class_method.to_sym, search)
        else
          model.where(method.to_sym => search)
        end
        items = query.limit(limit).order_by(order)
      end
    end
  end
end
