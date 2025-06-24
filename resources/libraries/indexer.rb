module Druid
  module Indexer
    def calculate_worker_capacity
      managers = node['redborder']['managers_per_services']['druid-indexer']
      total_tasks = node['redborder']['druid-indexer-tasks']

      # Mapping cores per indexer manager and sum total cores
      cores_per_node = managers.map { |name| [name, node['redborder']['cluster_info'][name]['cpu_cores']] }.to_h
      total_cores = cores_per_node.values.sum

      # Initial allocation by proportion
      allocations = cores_per_node.transform_values { |cores| (total_tasks * cores / total_cores.to_f).floor }

      # Distribute remaining tasks to nodes with the largest truncated fraction
      remaining = total_tasks - allocations.values.sum
      fractions = cores_per_node.map do |name, cores|
        ideal = total_tasks * cores / total_cores.to_f
        [name, ideal - allocations[name]]
      end

      fractions.sort_by { |_, f| -f }.take(remaining).each { |name, _| allocations[name] += 1 }

      # Return assignment for this node
      allocations.fetch(node['hostname'], 1)
    end
  end
end
