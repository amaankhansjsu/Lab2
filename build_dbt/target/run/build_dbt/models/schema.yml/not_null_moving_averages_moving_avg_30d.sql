select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select moving_avg_30d
from lab2.analytics.moving_averages
where moving_avg_30d is null



      
    ) dbt_internal_test