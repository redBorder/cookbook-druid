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
    end
end