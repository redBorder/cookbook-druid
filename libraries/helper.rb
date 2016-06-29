module Druid
   module Helper
      def delete_if_empty(directory)
         if Dir["#{directory}/*"].empty? 
            directory directory do
            action :delete
            end
         end
       end
    end
end