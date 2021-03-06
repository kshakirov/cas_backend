module TurboCassandra
  module Controller
    class Attribute
      def initialize
        @attribute = TurboCassandra::API::Attribute.new
      end

      def find_all
        @attribute.find_all
      end

      def find_by_code params
        @attribute.find(params['code'])
      end

      def find_by_codes body
        codes = JSON.parse body
        @attribute.find_by_codes(codes)
      end

      def find_by_set_name name
        @attribute.find_by_set_name name
      end

      def all
        @attribute.all
      end

      def create body
        attribute = JSON.parse body
        @attribute.create attribute
      end
    end
  end
end