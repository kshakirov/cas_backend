require_relative '../tools_helper'

cql = %Q(CREATE TABLE  featured_products
        (
            sku  bigint  PRIMARY KEY,
            data text
           ))
execute_lazy cql, []