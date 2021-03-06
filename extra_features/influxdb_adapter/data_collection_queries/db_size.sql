select
    tsd_timestamp as "timestamp",
    extract(epoch from tsd_timestamp::timestamp with time zone at time zone 'utc')::int as "time",
    tsize_b + isize_b as db_size_b,
    tsize_b,
    isize_b
from (
  select
    tsd_timestamp,
    sum(tsd_table_size)::int8 as tsize_b,
    sum(tsd_index_size)::int8 as isize_b
  from
    monitor_data.table_size_data
    join
    monitor_data.tables on t_id = tsd_table_id
  where
    tsd_timestamp > %(from_timestamp)s
    and tsd_timestamp <= %(to_timestamp)s
    and tsd_host_id = %(host_id)s
  group by
    tsd_timestamp
) a
where
  isize_b > 0
order by
  tsd_timestamp
