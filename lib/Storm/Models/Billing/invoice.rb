require 'Storm/Base/model'

module Storm
  module Models
    module Billing
      class Invoice < Storm::Base::Model
        attr_accessor :account
        attr_accessor :bill_date
        attr_accessor :due
        attr_accessor :end_date
        attr_accessor :lineitem_groups
        attr_accessor :payments
        attr_accessor :start_date
        attr_accessor :status
        attr_accessor :total
        attr_accessor :type

        def from_hash(h)
          super
          @account = h[:accnt]
          @bill_date = self.get_datetime h, :bill_date
          @due = h[:due]
          @end_date = self.get_datetime h, :end_date
          @lineitem_groups = self.get_array do |group|
            bg = BillGroup.new
            bg.from_hash group
            bg
          end
          @payments = self.get_array do |p|
            pm = Payment.new
            pm.from_hash p
            pm
          end
          @start_date = self.get_datetime h, :start_date
          @status = h[:status]
          @total = h[:total]
          @type = h[:type]
        end
      end

      class BillItem < Storm::Base::Model
        attr_accessor :charged_amount
        attr_accessor :end_date
        attr_accessor :description
        attr_accessor :quantity
        attr_accessor :start_date

        def from_hash(h)
          super
          @charged_amount = h[:charged_amount]
          @end_date = self.get_datetime h, :end_date
          @description = h[:item_description]
          @quantity = h[:quantity]
          @start_date = self.get_datetime h, :start_date
        end
      end

      class BillGroup < Storm::Base::Model
        attr_accessor :description
        attr_accessor :end_date
        attr_accessor :line_items
        attr_accessor :overdue
        attr_accessor :start_date
        attr_accessor :subtotal

        def from_hash(h)
          super
          @description = h[:description]
          @end_date = self.get_date h, :end_date
          @line_items = self.get_array do |l|
            item = BillItem.new
            item.from_hash l
            item
          end
          @overdue = h[:overdue]
          @start_date = self.get_date h, :start_date
          @subtotal = h[:subtotal]
        end
      end

      class Payment < Storm::Base::Model
        attr_accessor :account
        attr_accessor :amount
        attr_accessor :paid_date
        attr_accessor :type

        def from_hash(h)
          super
          @account = h[:account]
          @amount = h[:amount]
          @paid_date = self.get_datetime h, :paid_date
          @type = h[:type]
        end
      end
    end
  end
end
