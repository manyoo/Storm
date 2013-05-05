require 'Storm/Base/model'
require 'Storm/Base/sodserver'

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

        # Returns data specific to one invoice. In addition to what is returned
        # in the list method, additional details about the specific lineitems
        # are included in this method.
        def details
          raise 'uniq_id is not set for the current object' unless self.uniq_id
          data = Storm::Base::SODServer.remote_call '/Billing/Invoice/details',
                                                    :id => self.uniq_id
          self.from_hash data
        end

        # Returns a list of all the invoices for the logged in account.
        # Invoices are created at your regular billing date, but are also
        # created for one-off items like creating or cloning a server.
        #
        # @param num [Int] a positive integer for page number
        # @param size [Int] a positive integer for page size
        # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
        #                :page_size, :page_total and :items (an array of
        #                Invoice objects)
        def self.list(num, size)
          raise 'num and size must be positive' unless num > 0 and size > 0
          data = Storm::Base::SODServer.remote_call '/Billing/Invoice/list',
                                                    :page_num => num,
                                                    :page_size => size
          res = {}
          res[:item_count] = data[:item_count]
          res[:item_total] = data[:item_total]
          res[:page_num] = data[:page_num]
          res[:page_size] = data[:page_size]
          res[:page_total] = data[:page_total]
          res[:items] = data[:items].map do |i|
            item = Invoice.new
            item.from_hash i
            item
          end
        end

        # Returns a projection of what current account's next bill will look
        # like at their next bill date.
        # @return [Invoice] an Invoice object
        def self.next
          data = Storm::Base::SODServer.remote_call '/Billing/Invoice/next'
          inv = Invoice.new
          inv.from_hash data
          inv
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
