module Druid
   module Helper

      # Delete a directory if it is empty.
      def delete_if_empty(directory)
         if Dir["#{directory}/*"].empty? 
            directory directory do
            action :delete
            end
         end
      end

      # Check if all druid services are disabled.
      def all_services_disable?
      	node["druid"]["services"].map{|service,status| status}.all? {|status| !status }
      end

    end
end