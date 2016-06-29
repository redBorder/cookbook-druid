module Druid
    module Historical
        # Return heap_memory_kb and processing_memory_b
        # max_heap_kb -> Druid told: 'We recommend 250mb * (processing.numThreads) for the heap.'
        def compute_memory(memory_kb, threads, max_heap_kb = 250 * 1024 * threads, max_processing_kb = 1 * 1024 * 1024, min_processing_kb = 512 * 1024)
          heap, processing = search_multiple_max(memory_kb, threads, max_heap_kb, max_processing_kb, min_processing_kb)
         
          if heap < 0
            heap = (memory_kb * 0.6).to_i
            processing = ((memory_kb - heap) / (threads + 1)).to_i
          end
         
          return (heap), (processing * 1024)
        end
    
        # Search the max value to heap and processing based on restrictions. (Recursive)
        def search_multiple_max(memory_kb, threads, max_heap_kb, max_processing_kb, min_processing_kb)
          heap = memory_kb - (threads + 1) * max_processing_kb
          if max_processing_kb <= min_processing_kb
            return heap, max_processing_kb
          end
    
          if heap < max_heap_kb
           search_multiple_max(memory_kb, threads, max_heap_kb, max_processing_kb - min_processing_kb, min_processing_kb)
          else
           return max_heap_kb, max_processing_kb
          end
        end
    end
end