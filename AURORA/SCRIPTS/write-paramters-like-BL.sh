#!/bin/bash

# Script to apply and check VM tuning parameters

echo "Applying updates to VM tuning parameters..."

# Update compaction_proactiveness to 0 if not already set
current_value=$(cat /proc/sys/vm/compaction_proactiveness)
if [ "$current_value" -ne 0 ]; then
    echo 0 | sudo tee /proc/sys/vm/compaction_proactiveness
    echo "compaction_proactiveness set to 0"
else
    echo "compaction_proactiveness already set to 0"
fi

# Update swappiness to 10 if not already set
current_value=$(cat /proc/sys/vm/swappiness)
if [ "$current_value" -ne 10 ]; then
    echo 10 | sudo tee /proc/sys/vm/swappiness
    echo "swappiness set to 10"
else
    echo "swappiness already set to 10"
fi

# Update lru_gen_enabled to 0x0005 if not already set
current_value=$(cat /sys/kernel/mm/lru_gen/enabled)
if [ "$current_value" != "0x0005" ]; then
    echo 0x0005 | sudo tee /sys/kernel/mm/lru_gen/enabled
    echo "lru_gen_enabled set to 0x0005"
else
    echo "lru_gen_enabled already set to 0x0005"
fi

# Update zone_reclaim_mode to 0 if not already set
current_value=$(cat /proc/sys/vm/zone_reclaim_mode)
if [ "$current_value" -ne 0 ]; then
    echo 0 | sudo tee /proc/sys/vm/zone_reclaim_mode
    echo "zone_reclaim_mode set to 0"
else
    echo "zone_reclaim_mode already set to 0"
fi

# Update transparent_hugepage_enabled to madvise if not already set
current_value=$(cat /sys/kernel/mm/transparent_hugepage/enabled)
if [ "$current_value" != "always [madvise] never" ]; then
    echo "always madvise" | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
    echo "transparent_hugepage_enabled set to madvise"
else
    echo "transparent_hugepage_enabled already set to madvise"
fi

# Update transparent_hugepage_shmem_enabled to advise if not already set
current_value=$(cat /sys/kernel/mm/transparent_hugepage/shmem_enabled)
if [ "$current_value" != "always within_size [advise] never deny force" ]; then
    echo "always within_size advise" | sudo tee /sys/kernel/mm/transparent_hugepage/shmem_enabled
    echo "transparent_hugepage_shmem_enabled set to advise"
else
    echo "transparent_hugepage_shmem_enabled already set to advise"
fi

# Update transparent_hugepage_defrag to never if not already set
current_value=$(cat /sys/kernel/mm/transparent_hugepage/defrag)
if [ "$current_value" != "always defer defer+madvise madvise [never]" ]; then
    echo "always defer" | sudo tee /sys/kernel/mm/transparent_hugepage/defrag
    echo "transparent_hugepage_defrag set to never"
else
    echo "transparent_hugepage_defrag already set to never"
fi

# Update khugepaged_defrag to 0 if not already set
current_value=$(cat /sys/kernel/mm/transparent_hugepage/khugepaged/defrag)
if [ "$current_value" -ne 0 ]; then
    echo 0 | sudo tee /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
    echo "khugepaged_defrag set to 0"
else
    echo "khugepaged_defrag already set to 0"
fi

# Update page_lock_unfairness to 1 if not already set
current_value=$(cat /proc/sys/vm/page_lock_unfairness)
if [ "$current_value" -ne 1 ]; then
    echo 1 | sudo tee /proc/sys/vm/page_lock_unfairness
    echo "page_lock_unfairness set to 1"
else
    echo "page_lock_unfairness already set to 1"
fi

# Update sched_autogroup_enabled to 1 if not already set
current_value=$(cat /proc/sys/kernel/sched_autogroup_enabled)
if [ "$current_value" -ne 1 ]; then
    echo 1 | sudo tee /proc/sys/kernel/sched_autogroup_enabled
    echo "sched_autogroup_enabled set to 1"
else
    echo "sched_autogroup_enabled already set to 1"
fi

# Update sched_cfs_bandwidth_slice_us to 3000 if not already set
current_value=$(cat /proc/sys/kernel/sched_cfs_bandwidth_slice_us)
if [ "$current_value" -ne 3000 ]; then
    echo 3000 | sudo tee /proc/sys/kernel/sched_cfs_bandwidth_slice_us
    echo "sched_cfs_bandwidth_slice_us set to 3000"
else
    echo "sched_cfs_bandwidth_slice_us already set to 3000"
fi

# Update base_slice_ns to 3000000 if not already set
current_value=$(sudo cat /sys/kernel/debug/sched/base_slice_ns 2>/dev/null || echo "Permission denied")
if [ "$current_value" != "3000000" ]; then
    echo 3000000 | sudo tee /sys/kernel/debug/sched/base_slice_ns
    echo "base_slice_ns set to 3000000"
else
    echo "base_slice_ns already set to 3000000"
fi

# Update migration_cost_ns to 500000 if not already set
current_value=$(sudo cat /sys/kernel/debug/sched/migration_cost_ns 2>/dev/null || echo "Permission denied")
if [ "$current_value" != "500000" ]; then
    echo 500000 | sudo tee /sys/kernel/debug/sched/migration_cost_ns
    echo "migration_cost_ns set to 500000"
else
    echo "migration_cost_ns already set to 500000"
fi

# Update nr_migrate to 8 if not already set
current_value=$(sudo cat /sys/kernel/debug/sched/nr_migrate 2>/dev/null || echo "Permission denied")
if [ "$current_value" != "8" ]; then
    echo 8 | sudo tee /sys/kernel/debug/sched/nr_migrate
    echo "nr_migrate set to 8"
else
    echo "nr_migrate already set to 8"
fi

# Recheck the values after updates
echo "Rechecking updated values..."
echo "compaction_proactiveness: $(cat /proc/sys/vm/compaction_proactiveness)"
echo "swappiness: $(cat /proc/sys/vm/swappiness)"
echo "lru_gen_enabled: $(cat /sys/kernel/mm/lru_gen/enabled)"
echo "zone_reclaim_mode: $(cat /proc/sys/vm/zone_reclaim_mode)"
echo "transparent_hugepage_enabled: $(cat /sys/kernel/mm/transparent_hugepage/enabled)"
echo "transparent_hugepage_shmem_enabled: $(cat /sys/kernel/mm/transparent_hugepage/shmem_enabled)"
echo "transparent_hugepage_defrag: $(cat /sys/kernel/mm/transparent_hugepage/defrag)"
echo "khugepaged_defrag: $(cat /sys/kernel/mm/transparent_hugepage/khugepaged/defrag)"
echo "page_lock_unfairness: $(cat /proc/sys/vm/page_lock_unfairness)"
echo "sched_autogroup_enabled: $(cat /proc/sys/kernel/sched_autogroup_enabled)"
echo "sched_cfs_bandwidth_slice_us: $(cat /proc/sys/kernel/sched_cfs_bandwidth_slice_us)"
echo "base_slice_ns: $(sudo cat /sys/kernel/debug/sched/base_slice_ns 2>/dev/null || echo 'Permission denied')"
echo "migration_cost_ns: $(sudo cat /sys/kernel/debug/sched/migration_cost_ns 2>/dev/null || echo 'Permission denied')"
echo "nr_migrate: $(sudo cat /sys/kernel/debug/sched/nr_migrate 2>/dev/null || echo 'Permission denied')"

echo "Done checking."
