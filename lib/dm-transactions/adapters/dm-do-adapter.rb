module DataMapper
  class Transaction

    module DataObjectsAdapter
      extend Chainable

      # Produces a fresh transaction primitive for this Adapter
      #
      # Used by Transaction to perform its various tasks.
      #
      # @return [Object]
      #   a new Object that responds to :close, :begin, :commit,
      #   and :rollback,
      #
      # @api private
      def transaction_primitive
        DataObjects::Transaction.create_for_uri(normalized_uri)
      end

      # Pushes the given Transaction onto the per thread Transaction stack so
      # that everything done by this Adapter is done within the context of said
      # Transaction.
      #
      # @param [Transaction] transaction
      #   a Transaction to be the 'current' transaction until popped.
      #
      # @return [Array(Transaction)]
      #   the stack of active transactions for the current thread
      #
      # @api private
      def push_transaction(transaction)
        transactions << transaction
      end

      # Pop the 'current' Transaction from the per thread Transaction stack so
      # that everything done by this Adapter is no longer necessarily within the
      # context of said Transaction.
      #
      # @return [Transaction]
      #   the former 'current' transaction.
      #
      # @api private
      def pop_transaction
        transactions.pop
      end

      # Retrieve the current transaction for this Adapter.
      #
      # Everything done by this Adapter is done within the context of this
      # Transaction.
      #
      # @return [Transaction]
      #   the 'current' transaction for this Adapter.
      #
      # @api private
      def current_transaction
        transactions.last
      end

      chainable do
        protected

        # @api semipublic
        def open_connection
          current_connection || super
        end

        # @api semipublic
        def close_connection(connection)
          super unless current_connection.equal?(connection)
        end
      end

      private

      # @api private
      def transactions
        Thread.current[:dm_transactions] ||= []
      end

      # Retrieve the current connection for this Adapter.
      #
      # @return [Transaction]
      #   the 'current' connection for this Adapter.
      #
      # @api private
      def current_connection
        if transaction = current_transaction
          transaction.primitive_for(self).connection
        end
      end

    end # module DataObjectsAdapter

  end # class Transaction
end # module DataMapper