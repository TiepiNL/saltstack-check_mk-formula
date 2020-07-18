
sub human_size {
    my ( $size, $n ) = ( shift, 0 );
    ++$n and $size /= 1024 until $size < 1024;
    return sprintf "%.2f %s", $size, (qw[ bytes KB MB GB ])[$n];
}


# *** Performance schema ***

    # Top user per connection
    subheaderprint "Performance schema: Top 5 user per connection";
    my $nbL = 1;
    for my $lQuery (
        select_array(
'select user, total_connections from sys.user_summary order by total_connections desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery conn(s)";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top user per statement
    subheaderprint "Performance schema: Top 5 user per statement";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select user, statements from sys.user_summary order by statements desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery stmt(s)";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top user per statement latency
    subheaderprint "Performance schema: Top 5 user per statement latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select user, statement_avg_latency from sys.x\\$user_summary order by statement_avg_latency desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top user per lock latency
    subheaderprint "Performance schema: Top 5 user per lock latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select user, lock_latency from sys.x\\$user_summary_by_statement_latency order by lock_latency desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top user per full scans
    subheaderprint "Performance schema: Top 5 user per nb full scans";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select user, full_scans from sys.x\\$user_summary_by_statement_latency order by full_scans desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top user per row_sent
    subheaderprint "Performance schema: Top 5 user per rows sent";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select user, rows_sent from sys.x\\$user_summary_by_statement_latency order by rows_sent desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top user per row modified
    subheaderprint "Performance schema: Top 5 user per rows modified";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select user, rows_affected from sys.x\\$user_summary_by_statement_latency order by rows_affected desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top user per io
    subheaderprint "Performance schema: Top 5 user per io";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select user, file_ios from sys.x\\$user_summary order by file_ios desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top user per io latency
    subheaderprint "Performance schema: Top 5 user per io latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select user, file_io_latency from sys.x\\$user_summary order by file_io_latency desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top host per connection
    subheaderprint "Performance schema: Top 5 host per connection";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select host, total_connections from sys.x\\$host_summary order by total_connections desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery conn(s)";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top host per statement
    subheaderprint "Performance schema: Top 5 host per statement";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select host, statements from sys.x\\$host_summary order by statements desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery stmt(s)";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top host per statement latency
    subheaderprint "Performance schema: Top 5 host per statement latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select host, statement_avg_latency from sys.x\\$host_summary order by statement_avg_latency desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top host per lock latency
    subheaderprint "Performance schema: Top 5 host per lock latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select host, lock_latency from sys.x\\$host_summary_by_statement_latency order by lock_latency desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top host per full scans
    subheaderprint "Performance schema: Top 5 host per nb full scans";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select host, full_scans from sys.x\\$host_summary_by_statement_latency order by full_scans desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top host per rows sent
    subheaderprint "Performance schema: Top 5 host per rows sent";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select host, rows_sent from sys.x\\$host_summary_by_statement_latency order by rows_sent desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top host per rows modified
    subheaderprint "Performance schema: Top 5 host per rows modified";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select host, rows_affected from sys.x\\$host_summary_by_statement_latency order by rows_affected desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top host per io
    subheaderprint "Performance schema: Top 5 host per io";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select host, file_ios from sys.x\\$host_summary order by file_ios desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top 5 host per io latency
    subheaderprint "Performance schema: Top 5 host per io latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select host, file_io_latency from sys.x\\$host_summary order by file_io_latency desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top IO type order by total io
    subheaderprint "Performance schema: Top IO type order by total io";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select substring(event_name,14), SUM(total)AS total from sys.x\\$host_summary_by_file_io_type GROUP BY substring(event_name,14) ORDER BY total DESC;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery i/o";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top IO type order by total latency
    subheaderprint "Performance schema: Top IO type order by total latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select substring(event_name,14), ROUND(SUM(total_latency),1) AS total_latency from sys.x\\$host_summary_by_file_io_type GROUP BY substring(event_name,14) ORDER BY total_latency DESC;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top IO type order by max latency
    subheaderprint "Performance schema: Top IO type order by max latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select substring(event_name,14), MAX(max_latency) as max_latency from sys.x\\$host_summary_by_file_io_type GROUP BY substring(event_name,14) ORDER BY max_latency DESC;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top Stages order by total io
    subheaderprint "Performance schema: Top Stages order by total io";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select substring(event_name,7), SUM(total)AS total from sys.x\\$host_summary_by_stages GROUP BY substring(event_name,7) ORDER BY total DESC;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery i/o";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top Stages order by total latency
    subheaderprint "Performance schema: Top Stages order by total latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select substring(event_name,7), ROUND(SUM(total_latency),1) AS total_latency from sys.x\\$host_summary_by_stages GROUP BY substring(event_name,7) ORDER BY total_latency DESC;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top Stages order by avg latency
    subheaderprint "Performance schema: Top Stages order by avg latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select substring(event_name,7), MAX(avg_latency) as avg_latency from sys.x\\$host_summary_by_stages GROUP BY substring(event_name,7) ORDER BY avg_latency DESC;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top host per table scans
    subheaderprint "Performance schema: Top 5 host per table scans";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select host, table_scans from sys.x\\$host_summary order by table_scans desc LIMIT 5'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # InnoDB Buffer Pool by schema
    subheaderprint "Performance schema: InnoDB Buffer Pool by schema";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select object_schema, allocated, data, pages from sys.x\\$innodb_buffer_stats_by_schema ORDER BY pages DESC'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery page(s)";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # InnoDB Buffer Pool by table
    subheaderprint "Performance schema: 40 InnoDB Buffer Pool by table";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select object_schema,  object_name, allocated,data, pages from sys.x\\$innodb_buffer_stats_by_table ORDER BY pages DESC LIMIT 40'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery page(s)";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Process per allocated memory
    subheaderprint "Performance schema: Process per time";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select user, Command AS PROC, time from sys.x\\$processlist ORDER BY time DESC;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # InnoDB Lock Waits
    subheaderprint "Performance schema: InnoDB Lock Waits";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select wait_age_secs, locked_table, locked_type, waiting_query from sys.x\\$innodb_lock_waits order by wait_age_secs DESC;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Threads IO Latency
    subheaderprint "Performance schema: Thread IO Latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select user, total_latency, max_latency from sys.x\\$io_by_thread_by_latency order by total_latency DESC;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );



    # High Cost SQL statements
    subheaderprint "Performance schema: Top 15 Most latency statements";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select LEFT(query, 120), avg_latency from sys.x\\$statement_analysis order by avg_latency desc LIMIT 15'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top 5% slower queries
    subheaderprint "Performance schema: Top 15 slower queries";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select LEFT(query, 120), exec_count from sys.x\\$statements_with_runtimes_in_95th_percentile order by exec_count desc LIMIT 15'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery s";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top 10 nb statement type
    subheaderprint "Performance schema: Top 15 nb statement type";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select statement, sum(total) as total from sys.x\\$host_summary_by_statement_type group by statement order by total desc LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top statement by total latency
    subheaderprint "Performance schema: Top 15 statement by total latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select statement, sum(total_latency) as total from sys.x\\$host_summary_by_statement_type group by statement order by total desc LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top statement by lock latency
    subheaderprint "Performance schema: Top 15 statement by lock latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select statement, sum(lock_latency) as total from sys.x\\$host_summary_by_statement_type group by statement order by total desc LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top statement by full scans
    subheaderprint "Performance schema: Top 15 statement by full scans";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select statement, sum(full_scans) as total from sys.x\\$host_summary_by_statement_type group by statement order by total desc LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top statement by rows sent
    subheaderprint "Performance schema: Top 15 statement by rows sent";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select statement, sum(rows_sent) as total from sys.x\\$host_summary_by_statement_type group by statement order by total desc LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Top statement by rows modified
    subheaderprint "Performance schema: Top 15 statement by rows modified";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select statement, sum(rows_affected) as total from sys.x\\$host_summary_by_statement_type group by statement order by total desc LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Use temporary tables
    subheaderprint "Performance schema: 15 sample queries using temp table";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select left(query, 120) from sys.x\\$statements_with_temp_tables LIMIT 15'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Unused Indexes
    subheaderprint "Performance schema: Unused indexes";
    $nbL = 1;
    for my $lQuery ( select_array("select \* from sys.schema_unused_indexes where object_schema not in ('performance_schema')" )) {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Full table scans
    subheaderprint "Performance schema: Tables with full table scans";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select * from sys.x\\$schema_tables_with_full_table_scans order by rows_full_scanned DESC'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Latest file IO by latency
    subheaderprint "Performance schema: Latest FILE IO by latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select thread, file, latency, operation from sys.x\\$latest_file_io ORDER BY latency LIMIT 10;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # FILE by IO read bytes
    subheaderprint "Performance schema: FILE by IO read bytes";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select file, total_read from sys.x\\$io_global_by_file_by_bytes order by total_read DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # FILE by IO written bytes
    subheaderprint "Performance schema: FILE by IO written bytes";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select file, total_written from sys.x\\$io_global_by_file_by_bytes order by total_written DESC LIMIT 15'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # file per IO total latency
    subheaderprint "Performance schema: file per IO total latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select file, total_latency from sys.x\\$io_global_by_file_by_latency ORDER BY total_latency DESC LIMIT 20;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # file per IO read latency
    subheaderprint "Performance schema: file per IO read latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select file, read_latency from sys.x\\$io_global_by_file_by_latency ORDER BY read_latency DESC LIMIT 20;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # file per IO write latency
    subheaderprint "Performance schema: file per IO write latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select file, write_latency from sys.x\\$io_global_by_file_by_latency ORDER BY write_latency DESC LIMIT 20;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Event Wait by read bytes
    subheaderprint "Performance schema: Event Wait by read bytes";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select event_name, total_read from sys.x\\$io_global_by_wait_by_bytes order by total_read DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Event Wait by write bytes
    subheaderprint "Performance schema: Event Wait written bytes";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select event_name, total_written from sys.x\\$io_global_by_wait_by_bytes order by total_written DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # event per wait total latency
    subheaderprint "Performance schema: event per wait total latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select event_name, total_latency from sys.x\\$io_global_by_wait_by_latency ORDER BY total_latency DESC LIMIT 20;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # event per wait read latency
    subheaderprint "Performance schema: event per wait read latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select event_name, read_latency from sys.x\\$io_global_by_wait_by_latency ORDER BY read_latency DESC LIMIT 20;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # event per wait write latency
    subheaderprint "Performance schema: event per wait write latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select event_name, write_latency from sys.x\\$io_global_by_wait_by_latency ORDER BY write_latency DESC LIMIT 20;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    #schema_index_statistics
    # TOP 15 most read index
    subheaderprint "Performance schema: TOP 15 most read indexes";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name,index_name, rows_selected from sys.x\\$schema_index_statistics ORDER BY ROWs_selected DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # TOP 15 most used index
    subheaderprint "Performance schema: TOP 15 most modified indexes";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name,index_name, rows_inserted+rows_updated+rows_deleted AS changes from sys.x\\$schema_index_statistics ORDER BY rows_inserted+rows_updated+rows_deleted DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # TOP 15 high read latency index
    subheaderprint "Performance schema: TOP 15 high read latency index";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name,index_name, select_latency from sys.x\\$schema_index_statistics ORDER BY select_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # TOP 15 high insert latency index
    subheaderprint "Performance schema: TOP 15 most modified indexes";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name,index_name, insert_latency from sys.x\\$schema_index_statistics ORDER BY insert_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # TOP 15 high update latency index
    subheaderprint "Performance schema: TOP 15 high update latency index";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name,index_name, update_latency from sys.x\\$schema_index_statistics ORDER BY update_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # TOP 15 high delete latency index
    subheaderprint "Performance schema: TOP 15 high delete latency index";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name,index_name, delete_latency from sys.x\\$schema_index_statistics ORDER BY delete_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # TOP 15 most read tables
    subheaderprint "Performance schema: TOP 15 most read tables";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name, rows_fetched from sys.x\\$schema_table_statistics ORDER BY ROWs_fetched DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # TOP 15 most used tables
    subheaderprint "Performance schema: TOP 15 most modified tables";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name, rows_inserted+rows_updated+rows_deleted AS changes from sys.x\\$schema_table_statistics ORDER BY rows_inserted+rows_updated+rows_deleted DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # TOP 15 high read latency tables
    subheaderprint "Performance schema: TOP 15 high read latency tables";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name, fetch_latency from sys.x\\$schema_table_statistics ORDER BY fetch_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # TOP 15 high insert latency tables
    subheaderprint "Performance schema: TOP 15 high insert latency tables";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name, insert_latency from sys.x\\$schema_table_statistics ORDER BY insert_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # TOP 15 high update latency tables
    subheaderprint "Performance schema: TOP 15 high update latency tables";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name, update_latency from sys.x\\$schema_table_statistics ORDER BY update_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # TOP 15 high delete latency tables
    subheaderprint "Performance schema: TOP 15 high delete latency tables";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select table_schema, table_name, delete_latency from sys.x\\$schema_table_statistics ORDER BY delete_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    # Redundant indexes
    subheaderprint "Performance schema: Redundant indexes";
    $nbL = 1;
    for my $lQuery (
        select_array('use sys;select * from schema_redundant_indexes;') )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: Table not using InnoDB buffer";
    $nbL = 1;
    for my $lQuery (
        select_array(
' Select table_schema, table_name from sys.x\\$schema_table_statistics_with_buffer where innodb_buffer_allocated IS NULL;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: Top 15 Tables using InnoDB buffer";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select table_schema,table_name,innodb_buffer_allocated from sys.x\\$schema_table_statistics_with_buffer where innodb_buffer_allocated IS NOT NULL ORDER BY innodb_buffer_allocated DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: Top 15 Tables with InnoDB buffer free";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select table_schema,table_name,innodb_buffer_free from sys.x\\$schema_table_statistics_with_buffer where innodb_buffer_allocated IS NOT NULL ORDER BY innodb_buffer_free DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: Top 15 Most executed queries";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select db, LEFT(query, 120), exec_count from sys.x\\$statement_analysis order by exec_count DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint
      "Performance schema: Latest SQL queries in errors or warnings";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select LEFT(query, 120), last_seen from sys.x\\$statements_with_errors_or_warnings ORDER BY last_seen LIMIT 40;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: Top 20 queries with full table scans";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select db, LEFT(query, 120), exec_count from sys.x\\$statements_with_full_table_scans order BY exec_count DESC LIMIT 20;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: Last 50 queries with full table scans";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select db, LEFT(query, 120), last_seen from sys.x\\$statements_with_full_table_scans order BY last_seen DESC LIMIT 50;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 15 reader queries (95% percentile)";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select db, LEFT(query, 120), rows_sent from sys.x\\$statements_with_runtimes_in_95th_percentile ORDER BY ROWs_sent DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint
      "Performance schema: TOP 15 most row look queries (95% percentile)";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select db, LEFT(query, 120), rows_examined AS search from sys.x\\$statements_with_runtimes_in_95th_percentile ORDER BY rows_examined DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint
      "Performance schema: TOP 15 total latency queries (95% percentile)";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select db, LEFT(query, 120), total_latency AS search from sys.x\\$statements_with_runtimes_in_95th_percentile ORDER BY total_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint
      "Performance schema: TOP 15 max latency queries (95% percentile)";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select db, LEFT(query, 120), max_latency AS search from sys.x\\$statements_with_runtimes_in_95th_percentile ORDER BY max_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint
      "Performance schema: TOP 15 average latency queries (95% percentile)";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select db, LEFT(query, 120), avg_latency AS search from sys.x\\$statements_with_runtimes_in_95th_percentile ORDER BY avg_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: Top 20 queries with sort";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select db, LEFT(query, 120), exec_count from sys.x\\$statements_with_sorting order BY exec_count DESC LIMIT 20;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: Last 50 queries with sort";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select db, LEFT(query, 120), last_seen from sys.x\\$statements_with_sorting order BY last_seen DESC LIMIT 50;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 15 row sorting queries with sort";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select db, LEFT(query, 120), rows_sorted from sys.x\\$statements_with_sorting ORDER BY ROWs_sorted DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 15 total latency queries with sort";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select db, LEFT(query, 120), total_latency AS search from sys.x\\$statements_with_sorting ORDER BY total_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 15 merge queries with sort";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select db, LEFT(query, 120), sort_merge_passes AS search from sys.x\\$statements_with_sorting ORDER BY sort_merge_passes DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint
      "Performance schema: TOP 15 average sort merges queries with sort";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select db, LEFT(query, 120), avg_sort_merges AS search from sys.x\\$statements_with_sorting ORDER BY avg_sort_merges DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 15 scans queries with sort";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select db, LEFT(query, 120), sorts_using_scans AS search from sys.x\\$statements_with_sorting ORDER BY sorts_using_scans DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 15 range queries with sort";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select db, LEFT(query, 120), sort_using_range AS search from sys.x\\$statements_with_sorting ORDER BY sort_using_range DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );
	  

##################################################################################

    #statements_with_temp_tables

#mysql> desc statements_with_temp_tables;
#+--------------------------+---------------------+------+-----+---------------------+-------+
#| Field                    | Type                | Null | Key | Default             | Extra |
#+--------------------------+---------------------+------+-----+---------------------+-------+
#| query                    | longtext            | YES  |     | NULL                |       |
#| db                       | varchar(64)         | YES  |     | NULL                |       |
#| exec_count               | bigint(20) unsigned | NO   |     | NULL                |       |
#| total_latency            | text                | YES  |     | NULL                |       |
#| memory_tmp_tables        | bigint(20) unsigned | NO   |     | NULL                |       |
#| disk_tmp_tables          | bigint(20) unsigned | NO   |     | NULL                |       |
#| avg_tmp_tables_per_query | decimal(21,0)       | NO   |     | 0                   |       |
#| tmp_tables_to_disk_pct   | decimal(24,0)       | NO   |     | 0                   |       |
#| first_seen               | timestamp           | NO   |     | 0000-00-00 00:00:00 |       |
#| last_seen                | timestamp           | NO   |     | 0000-00-00 00:00:00 |       |
#| digest                   | varchar(32)         | YES  |     | NULL                |       |
#+--------------------------+---------------------+------+-----+---------------------+-------+
#11 rows in set (0,01 sec)#
#
    subheaderprint "Performance schema: Top 20 queries with temp table";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select db, LEFT(query, 120), exec_count from sys.x\\$statements_with_temp_tables order BY exec_count DESC LIMIT 20;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: Last 50 queries with temp table";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select db, LEFT(query, 120), last_seen from sys.x\\$statements_with_temp_tables order BY last_seen DESC LIMIT 50;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint
      "Performance schema: TOP 15 total latency queries with temp table";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select db, LEFT(query, 120), total_latency AS search from sys.x\\$statements_with_temp_tables ORDER BY total_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 15 queries with temp table to disk";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select db, LEFT(query, 120), disk_tmp_tables from sys.x\\$statements_with_temp_tables ORDER BY disk_tmp_tables DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

##################################################################################
    #wait_classes_global_by_latency

#ysql> select * from wait_classes_global_by_latency;
#-----------------+-------+---------------+-------------+-------------+-------------+
# event_class     | total | total_latency | min_latency | avg_latency | max_latency |
#-----------------+-------+---------------+-------------+-------------+-------------+
# wait/io/file    | 15381 | 1.23 s        | 0 ps        | 80.12 us    | 230.64 ms   |
# wait/io/table   |    59 | 7.57 ms       | 5.45 us     | 128.24 us   | 3.95 ms     |
# wait/lock/table |    69 | 3.22 ms       | 658.84 ns   | 46.64 us    | 1.10 ms     |
#-----------------+-------+---------------+-------------+-------------+-------------+
# rows in set (0,00 sec)

    subheaderprint "Performance schema: TOP 15 class events by number";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select event_class, total from sys.x\\$wait_classes_global_by_latency ORDER BY total DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 30 events by number";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select events, total from sys.x\\$waits_global_by_latency ORDER BY total DESC LIMIT 30;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 15 class events by total latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select event_class, total_latency from sys.x\\$wait_classes_global_by_latency ORDER BY total_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 30 events by total latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'use sys;select events, total_latency from sys.x\\$waits_global_by_latency ORDER BY total_latency DESC LIMIT 30;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 15 class events by max latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select event_class, max_latency from sys.x\\$wait_classes_global_by_latency ORDER BY max_latency DESC LIMIT 15;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

    subheaderprint "Performance schema: TOP 30 events by max latency";
    $nbL = 1;
    for my $lQuery (
        select_array(
'select events, max_latency from sys.x\\$waits_global_by_latency ORDER BY max_latency DESC LIMIT 30;'
        )
      )
    {
        infoprint " +-- $nbL: $lQuery";
        $nbL++;
    }
    infoprint "No information found or indicators deactivated."
      if ( $nbL == 1 );

}










# *** Database Metrics ***

    my @dblist = select_array(
"SELECT DISTINCT TABLE_SCHEMA FROM information_schema.TABLES WHERE TABLE_SCHEMA NOT IN ( 'mysql', 'performance_schema', 'information_schema', 'sys' );"
    );
    infoprint "There is " . scalar(@dblist) . " Database(s).";
    my @totaldbinfo = split /\s/,
      select_one(
"SELECT SUM(TABLE_ROWS), SUM(DATA_LENGTH), SUM(INDEX_LENGTH) , SUM(DATA_LENGTH+INDEX_LENGTH), COUNT(TABLE_NAME),COUNT(DISTINCT(TABLE_COLLATION)),COUNT(DISTINCT(ENGINE)) FROM information_schema.TABLES WHERE TABLE_SCHEMA NOT IN ( 'mysql', 'performance_schema', 'information_schema', 'sys' );"
      );
    infoprint "All User Databases:";
    infoprint " +-- TABLE : "
      . ( $totaldbinfo[4] eq 'NULL' ? 0 : $totaldbinfo[4] ) . "";
    infoprint " +-- ROWS  : "
      . ( $totaldbinfo[0] eq 'NULL' ? 0 : $totaldbinfo[0] ) . "";
    infoprint " +-- DATA  : "
      . hr_bytes( $totaldbinfo[1] ) . "("
      . percentage( $totaldbinfo[1], $totaldbinfo[3] ) . "%)";
    infoprint " +-- INDEX : "
      . hr_bytes( $totaldbinfo[2] ) . "("
      . percentage( $totaldbinfo[2], $totaldbinfo[3] ) . "%)";
    infoprint " +-- SIZE  : " . hr_bytes( $totaldbinfo[3] ) . "";
    infoprint " +-- COLLA : "
      . ( $totaldbinfo[5] eq 'NULL' ? 0 : $totaldbinfo[5] ) . " ("
      . (
        join ", ",
        select_array(
            "SELECT DISTINCT(TABLE_COLLATION) FROM information_schema.TABLES;")
      ) . ")";
    infoprint " +-- ENGIN : "
      . ( $totaldbinfo[6] eq 'NULL' ? 0 : $totaldbinfo[6] ) . " ("
      . (
        join ", ",
        select_array("SELECT DISTINCT(ENGINE) FROM information_schema.TABLES;")
      ) . ")";

    $result{'Databases'}{'All databases'}{'Rows'} =
      ( $totaldbinfo[0] eq 'NULL' ? 0 : $totaldbinfo[0] );
    $result{'Databases'}{'All databases'}{'Data Size'} = $totaldbinfo[1];
    $result{'Databases'}{'All databases'}{'Data Pct'} =
      percentage( $totaldbinfo[1], $totaldbinfo[3] ) . "%";
    $result{'Databases'}{'All databases'}{'Index Size'} = $totaldbinfo[2];
    $result{'Databases'}{'All databases'}{'Index Pct'} =
      percentage( $totaldbinfo[2], $totaldbinfo[3] ) . "%";
    $result{'Databases'}{'All databases'}{'Total Size'} = $totaldbinfo[3];
    print "\n" unless ( $opt{'silent'} or $opt{'json'} );

    foreach (@dblist) {
        my @dbinfo = split /\s/,
          select_one(
"SELECT TABLE_SCHEMA, SUM(TABLE_ROWS), SUM(DATA_LENGTH), SUM(INDEX_LENGTH) , SUM(DATA_LENGTH+INDEX_LENGTH), COUNT(DISTINCT ENGINE),COUNT(TABLE_NAME),COUNT(DISTINCT(TABLE_COLLATION)),COUNT(DISTINCT(ENGINE)) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$_' GROUP BY TABLE_SCHEMA ORDER BY TABLE_SCHEMA"
          );
        next unless defined $dbinfo[0];
        infoprint "Database: " . $dbinfo[0] . "";
        infoprint " +-- TABLE: "
          . ( !defined( $dbinfo[6] ) or $dbinfo[6] eq 'NULL' ? 0 : $dbinfo[6] )
          . "";
        infoprint " +-- COLL : "
          . ( $dbinfo[7] eq 'NULL' ? 0 : $dbinfo[7] ) . " ("
          . (
            join ", ",
            select_array(
"SELECT DISTINCT(TABLE_COLLATION) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$_';"
            )
          ) . ")";
        infoprint " +-- ROWS : "
          . ( !defined( $dbinfo[1] ) or $dbinfo[1] eq 'NULL' ? 0 : $dbinfo[1] )
          . "";
        infoprint " +-- DATA : "
          . hr_bytes( $dbinfo[2] ) . "("
          . percentage( $dbinfo[2], $dbinfo[4] ) . "%)";
        infoprint " +-- INDEX: "
          . hr_bytes( $dbinfo[3] ) . "("
          . percentage( $dbinfo[3], $dbinfo[4] ) . "%)";
        infoprint " +-- TOTAL: " . hr_bytes( $dbinfo[4] ) . "";
        infoprint " +-- ENGIN : "
          . ( $dbinfo[8] eq 'NULL' ? 0 : $dbinfo[8] ) . " ("
          . (
            join ", ",
            select_array(
"SELECT DISTINCT(ENGINE) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$_'"
            )
          ) . ")";
        badprint "Index size is larger than data size for $dbinfo[0] \n"
          if ( $dbinfo[2] ne 'NULL' )
          and ( $dbinfo[3] ne 'NULL' )
          and ( $dbinfo[2] < $dbinfo[3] );
        badprint "There are " . $dbinfo[5] . " storage engines. Be careful. \n"
          if $dbinfo[5] > 1;
        $result{'Databases'}{ $dbinfo[0] }{'Rows'}       = $dbinfo[1];
        $result{'Databases'}{ $dbinfo[0] }{'Tables'}     = $dbinfo[6];
        $result{'Databases'}{ $dbinfo[0] }{'Collations'} = $dbinfo[7];
        $result{'Databases'}{ $dbinfo[0] }{'Data Size'}  = $dbinfo[2];
        $result{'Databases'}{ $dbinfo[0] }{'Data Pct'} =
          percentage( $dbinfo[2], $dbinfo[4] ) . "%";
        $result{'Databases'}{ $dbinfo[0] }{'Index Size'} = $dbinfo[3];
        $result{'Databases'}{ $dbinfo[0] }{'Index Pct'} =
          percentage( $dbinfo[3], $dbinfo[4] ) . "%";
        $result{'Databases'}{ $dbinfo[0] }{'Total Size'} = $dbinfo[4];

        if ( $dbinfo[7] > 1 ) {
            badprint $dbinfo[7]
              . " different collations for database "
              . $dbinfo[0];
            push( @generalrec,
                "Check all table collations are identical for all tables in "
                  . $dbinfo[0]
                  . " database." );
        }
        else {
            goodprint $dbinfo[7]
              . " collation for "
              . $dbinfo[0]
              . " database.";
        }
        if ( $dbinfo[8] > 1 ) {
            badprint $dbinfo[8]
              . " different engines for database "
              . $dbinfo[0];
            push( @generalrec,
                    "Check all table engines are identical for all tables in "
                  . $dbinfo[0]
                  . " database." );
        }
        else {
            goodprint $dbinfo[8] . " engine for " . $dbinfo[0] . " database.";
        }

        my @distinct_column_charset = select_array(
"select DISTINCT(CHARACTER_SET_NAME) from information_schema.COLUMNS where CHARACTER_SET_NAME IS NOT NULL AND TABLE_SCHEMA ='$_'"
        );
        infoprint "Charsets for $dbinfo[0] database table column: "
          . join( ', ', @distinct_column_charset );
        if ( scalar(@distinct_column_charset) > 1 ) {
            badprint $dbinfo[0]
              . " table column(s) has several charsets defined for all text like column(s).";
            push( @generalrec,
                    "Limit charset for column to one charset if possible for "
                  . $dbinfo[0]
                  . " database." );
        }
        else {
            goodprint $dbinfo[0]
              . " table column(s) has same charset defined for all text like column(s).";
        }

        my @distinct_column_collation = select_array(
"select DISTINCT(COLLATION_NAME) from information_schema.COLUMNS where COLLATION_NAME IS NOT NULL AND TABLE_SCHEMA ='$_'"
        );
        infoprint "Collations for $dbinfo[0] database table column: "
          . join( ', ', @distinct_column_collation );
        if ( scalar(@distinct_column_collation) > 1 ) {
            badprint $dbinfo[0]
              . " table column(s) has several collations defined for all text like column(s).";
            push( @generalrec,
                "Limit collations for column to one collation if possible for "
                  . $dbinfo[0]
                  . " database." );
        }
        else {
            goodprint $dbinfo[0]
              . " table column(s) has same collation defined for all text like column(s).";
        }
    }

}

# Recommendations for database columns
sub mysql_tables {

    if (mysql_version_ge(8) and not mysql_version_eq(10)) {
        infoprint "MySQL and Percona version 8 and greater have remove PROCEDURE ANALYSE feature"
    }
    my @dblist = select_array(
"SELECT DISTINCT TABLE_SCHEMA FROM information_schema.TABLES WHERE TABLE_SCHEMA NOT IN ( 'mysql', 'performance_schema', 'information_schema', 'sys' );"
    );
    foreach (@dblist) {
        my $dbname = $_;
        next unless defined $_;
        infoprint "Database: " . $_ . "";
        my @dbtable = select_array(
"SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA='$dbname' AND TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME"
        );
        foreach (@dbtable) {
            my $tbname = $_;
            infoprint " +-- TABLE: $tbname";
            my @tbcol = select_array(
"SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='$dbname' AND TABLE_NAME='$tbname'"
            );
            foreach (@tbcol) {
                my $ctype = select_one(
"SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='$dbname' AND TABLE_NAME='$tbname' AND COLUMN_NAME='$_' "
                );
                my $isnull = select_one(
"SELECT IS_NULLABLE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='$dbname' AND TABLE_NAME='$tbname' AND COLUMN_NAME='$_' "
                );

                infoprint "     +-- Column $tbname.$_:";
                my $current_type =
                  uc($ctype) . ( $isnull eq 'NO' ? " NOT NULL" : "" );
                my $optimal_type='';
                $optimal_type = select_str_g( "Optimal_fieldtype",
"SELECT \\`$_\\` FROM \\`$dbname\\`.\\`$tbname\\` PROCEDURE ANALYSE(100000)"
                ) unless (mysql_version_ge(8) and not mysql_version_eq(10));
                if ( $optimal_type eq '' ) {
                    infoprint "      Current Fieldtype: $current_type";
                    #infoprint "      Optimal Fieldtype: Not available";
                }
                elsif ( $current_type ne $optimal_type and $current_type !~ /.*DATETIME.*/ and $current_type !~ /.*TIMESTAMP.*/) {
                    infoprint "      Current Fieldtype: $current_type";
                    if ($optimal_type =~ /.*ENUM\(.*/ ) {
                        $optimal_type ="ENUM( ... )";
                    }
                    infoprint "      Optimal Fieldtype: $optimal_type ";
                    if ($optimal_type !~ /.*ENUM\(.*/ ) {
                        badprint
"Consider changing type for column $_ in table $dbname.$tbname";
                    push( @generalrec,
"ALTER TABLE \`$dbname\`.\`$tbname\` MODIFY \`$_\` $optimal_type;"
                    );
                }

                }
                else {
                    goodprint "$dbname.$tbname ($_) type: $current_type";
                }
            }
        }

    }
}

# Recommendations for Indexes metrics
sub mysql_indexes {
    return if ( $opt{idxstat} == 0 );

    subheaderprint "Indexes Metrics";

    my @idxinfo = select_array($selIdxReq);
    infoprint "Worst selectivity indexes:";
    foreach (@idxinfo) {
        debugprint "$_";
        my @info = split /\s/;
        infoprint "Index: " . $info[1] . "";

        infoprint " +-- COLUMN      : " . $info[0] . "";
        infoprint " +-- NB SEQS     : " . $info[2] . " sequence(s)";
        infoprint " +-- NB COLS     : " . $info[3] . " column(s)";
        infoprint " +-- CARDINALITY : " . $info[4] . " distinct values";
        infoprint " +-- NB ROWS     : " . $info[5] . " rows";
        infoprint " +-- TYPE        : " . $info[6];
        infoprint " +-- SELECTIVITY : " . $info[7] . "%";

        $result{'Indexes'}{ $info[1] }{'Column'}           = $info[0];
        $result{'Indexes'}{ $info[1] }{'Sequence number'}  = $info[2];
        $result{'Indexes'}{ $info[1] }{'Number of column'} = $info[3];
        $result{'Indexes'}{ $info[1] }{'Cardinality'}      = $info[4];
        $result{'Indexes'}{ $info[1] }{'Row number'}       = $info[5];
        $result{'Indexes'}{ $info[1] }{'Index Type'}       = $info[6];
        $result{'Indexes'}{ $info[1] }{'Selectivity'}      = $info[7];
        if ( $info[7] < 25 ) {
            badprint "$info[1] has a low selectivity";
        }
    }

    return
      unless ( defined( $myvar{'performance_schema'} )
        and $myvar{'performance_schema'} eq 'ON' );


    @idxinfo = select_array($selIdxReq);
    infoprint "Unused indexes:";
    push( @generalrec, "Remove unused indexes." ) if ( scalar(@idxinfo) > 0 );
    foreach (@idxinfo) {
        debugprint "$_";
        my @info = split /\s/;
        badprint "Index: $info[1] on $info[0] is not used.";
        push @{ $result{'Indexes'}{'Unused Indexes'} },
          $info[0] . "." . $info[1];
    }
}














# *** Galera Metrics ***

    # Galera Cluster
    unless ( defined $myvar{'have_galera'}
        && $myvar{'have_galera'} eq "YES" )
    {
        infoprint "Galera is disabled.";
        return;
    }
    infoprint "Galera is enabled.";

    if ( get_wsrep_option('wsrep_flow_control_paused') > 0.02 ) {
        badprint "Fraction of time node pause flow control > 0.02";
    }
    else {
        goodprint
"Flow control fraction seems to be OK (wsrep_flow_control_paused<=0.02)";
    }



    infoprint "Read consistency mode :" . $myvar{'wsrep_causal_reads'};

...
    else {
        badprint "Galera WsREP is disabled";
    }

    if ( defined( $mystat{'wsrep_connected'} )
        and $mystat{'wsrep_connected'} eq "ON" )
    {
        goodprint "Node is connected";
    }
    else {
        badprint "Node is disconnected";
    }
    if ( defined( $mystat{'wsrep_ready'} ) and $mystat{'wsrep_ready'} eq "ON" )
    {
        goodprint "Node is ready";
    }
    else {
        badprint "Node is not ready";
    }
    infoprint "Cluster status :" . $mystat{'wsrep_cluster_status'};
    if ( defined( $mystat{'wsrep_cluster_status'} )
        and $mystat{'wsrep_cluster_status'} eq "Primary" )
    {
        goodprint "Galera cluster is consistent and ready for operations";
    }
    else {
        badprint "Cluster is not consistent and ready";
    }
    if ( $mystat{'wsrep_local_state_uuid'} eq
        $mystat{'wsrep_cluster_state_uuid'} )
    {
        goodprint "Node and whole cluster at the same level: "
          . $mystat{'wsrep_cluster_state_uuid'};
    }
    else {
        badprint "Node and whole cluster not the same level";
        infoprint "Node    state uuid: " . $mystat{'wsrep_local_state_uuid'};
        infoprint "Cluster state uuid: " . $mystat{'wsrep_cluster_state_uuid'};
    }
    if ( $mystat{'wsrep_local_state_comment'} eq 'Synced' ) {
        goodprint "Node is synced with whole cluster.";
    }
    else {
        badprint "Node is not synced";
        infoprint "Node State : " . $mystat{'wsrep_local_state_comment'};
    }
    if ( $mystat{'wsrep_local_cert_failures'} == 0 ) {
        goodprint "There is no certification failures detected.";
    }
    else {
        badprint "There is "
          . $mystat{'wsrep_local_cert_failures'}
          . " certification failure(s)detected.";
    }












