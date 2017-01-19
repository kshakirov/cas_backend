require_relative '../tools_helper'

cql = %Q(CREATE TABLE  visitor_logs
        (
            visitor_id uuid,
            date timestamp,
            id timeuuid,
            ip inet,
            customer_id bigint,
            product bigint, Primary Key(visitor_id, date, id, ip, customer_id)))
execute_lazy cql, []